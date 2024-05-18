#ifndef QTMAP_MAINWINDOW_H
#define QTMAP_MAINWINDOW_H

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui {
	class MainWindow;
}
QT_END_NAMESPACE

class mainwindow: public QMainWindow
{
Q_OBJECT
public:
	explicit mainwindow(QWidget *parent = nullptr);
	~mainwindow();
signals:
	void addLocationMarker(QVariant, QVariant);
	void setCenterPosition(QVariant, QVariant);
	void setZoom(QVariant);
private:
	std::unique_ptr<Ui::MainWindow> ui;
};


#endif //QTMAP_MAINWINDOW_H
