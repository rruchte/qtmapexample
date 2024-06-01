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
        root.center = QtPositioning.coordinate(lat, lng);
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

        // When the second marker is added, draw a line between the two
        if(mapItems.length === 2)
        {
            addPolyline(QtPositioning.coordinate(mapItems[0].coordinate.latitude, mapItems[0].coordinate.longitude), QtPositioning.coordinate(mapItems[1].coordinate.latitude, mapItems[1].coordinate.longitude));
        }

        // Automatically pan and zoom so that all markers are visible
        if(mapItems.length > 1)
        {
            fitViewportToVisibleMapItems();
        }

    }

    // Add a line to the map
    function addPolyline(coord1, coord2)
    {
        // Instantiate our simple polyline component, pass our two coordinates in the path property
        var item = polyline.createObject(root, {
            path: [
                coord1,
                coord2
            ]
        });

        // Add the polyline instance to the map
        addMapItem(item);
    }

    // Define our map marker component
    Component
    {
        id: locationMarker
        MapQuickItem
        {
            id: markerImg
            anchorPoint.x: image.width / 2 // This will center the marker on the longitude
            anchorPoint.y: image.height // This will place the tip of the marker on the latitude
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

    // Define our polyline component
    Component
    {
        id: polyline
        MapPolyline {
            id: polylineInstance
            line.width: 2
            line.color: 'green'
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