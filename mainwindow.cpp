#include <QQmlEngine>
#include <QQuickItem>
#include <QTimer>

#include "mainwindow.h"
#include "ui_mainwindow.h"

mainwindow::mainwindow(QWidget *parent) :
		QMainWindow(parent),
		ui(new Ui::MainWindow)
{
	ui->setupUi(this);

	// This is critical, without this the map will appear blank!
	ui->map->setResizeMode(QQuickWidget::SizeRootObjectToView);

	// Load our QML into the QQuickWidget defined in mainwindow.ui
	ui->map->setSource(QUrl("qrc:/map.qml"));

	// If there are errors, send them to debug stream
	QList<QQmlError> err = ui->map->errors();
	for (QList<QQmlError>::iterator i = err.begin(); i != err.end(); ++i)
	{
		qDebug() << *i;
	}

	// Get a pointer to the map QQuickItem so we can wire up our connections
	QQuickItem *mapObj = ui->map->rootObject();
	connect(this, SIGNAL(addLocationMarker(QVariant,QVariant)), mapObj, SLOT(addLocationMarker(QVariant,QVariant)));
	connect(this, SIGNAL(setCenterPosition(QVariant,QVariant)), mapObj, SLOT(setCenterPosition(QVariant,QVariant)));
	connect(this, SIGNAL(setZoom(QVariant)), mapObj, SLOT(setZoom(QVariant)));

	// Update the map center and zoom, put it on a timer so we can see the initial map state first
	QTimer::singleShot( 5000, this, [this](){
		emit setCenterPosition(35.9205459,-75.6576803);
		emit setZoom(7);
	});

	// Add a marker after a delay to see the results of the center & zoom operations
	QTimer::singleShot( 10000, this, [this](){
		emit addLocationMarker(35.2527373,-75.5274529);
	});
}

mainwindow::~mainwindow(){}