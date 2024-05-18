import QtQuick
import QtLocation
import QtPositioning

Map {
    id: root
    anchors.fill: parent
    plugin: mapPlugin

    Plugin {
        id: mapPlugin
        name: "osm"
        // Directly specify the tile server, this avoids the "API KEY REQUIRED" watermark
        PluginParameter { name: "osm.mapping.host"; value: "https://tile.openstreetmap.org/" }
        // Be courteous, tell the OSM who we are
        PluginParameter { name: "osm.useragent"; value: "qtmap" }
    }

    property double latitude: 39.50
    property double longitude: -98.35
    property Component locationmarker: locationMarker

    center: QtPositioning.coordinate(latitude, longitude) // Default to center of US
    zoomLevel: 4 // Zoom at a level where the entire US is shown in the viewport

    /*
        When we directly specify the tile server in osm.mapping.host, a custom map type will be added to the
        end of the supportedMapTypes list, so we need to specify the last item in the list
    */
    activeMapType: supportedMapTypes[supportedMapTypes.length - 1]

    function setCenterPosition(lat, lng)
    {
        pan(latitude - lat, longitude - lng);
        latitude = lat;
        longitude = lng;
    }

    function setZoom(zoom)
    {
        zoomLevel = zoom;
    }

    function addLocationMarker(lat, lng)
    {
        var item = locationMarker.createObject(root, {
            coordinate:QtPositioning.coordinate(lat, lng)
        });

        addMapItem(item);

        setCenterPosition(lat, lng);
        zoomLevel = 10
    }

    // Define our map marker component
    Component
    {
        id: locationMarker
        MapQuickItem
        {
            id: markerImg
            anchorPoint.x: image.width / 4
            anchorPoint.y: image.height
            coordinate: position
            sourceItem: Image {
                id: image
                width: 32
                height: 32
                source: "qrc:/images/map-marker.svg"
                sourceSize: Qt.size(80, 80)
                smooth: true
                antialiasing: true
            }
        }
    }

    // Log out some debug info when we finish loading
    Component.onCompleted: {
        console.log("Map Types: ", supportedMapTypes)
        console.log("Active Map Type: ", activeMapType)
    }

    // Set up all of our interaction handlers
    PinchHandler {
        id: pinch
        target: null
        onActiveChanged: if (active) {
            startCentroid = toCoordinate(pinch.centroid.position, false)
        }
        onScaleChanged: (delta) => {
            zoomLevel += Math.log2(delta)
            alignCoordinateToPoint(startCentroid, pinch.centroid.position)
        }
        onRotationChanged: (delta) => {
            bearing -= delta
            alignCoordinateToPoint(startCentroid, pinch.centroid.position)
        }
        grabPermissions: PointerHandler.TakeOverForbidden
    }

    WheelHandler {
        id: wheel
        // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
        // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
        // and we don't yet distinguish mice and trackpads on Wayland either
        acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
            ? PointerDevice.Mouse | PointerDevice.TouchPad
            : PointerDevice.Mouse
        rotationScale: 1/120
        property: "zoomLevel"
    }

    DragHandler {
        id: drag
        target: null
        onTranslationChanged: (delta) => pan(-delta.x, -delta.y)
    }

    Shortcut {
        enabled: zoomLevel < maximumZoomLevel
        sequence: StandardKey.ZoomIn
        onActivated: zoomLevel = Math.round(zoomLevel + 1)
    }

    Shortcut {
        enabled: zoomLevel > minimumZoomLevel
        sequence: StandardKey.ZoomOut
        onActivated: zoomLevel = Math.round(zoomLevel - 1)
    }
}