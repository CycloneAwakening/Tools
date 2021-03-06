#ifndef TREEMODEL_H
#define TREEMODEL_H

#include <QAbstractItemModel>
#include <QModelIndex>
#include <QVariant>
#include <QMap>
#include <QPair>

#include "treetype.h"
#include "node.h"

class TypeGroup;

class TreeModel : public QAbstractItemModel
{
	Q_OBJECT

public:
	TreeModel(QObject *parent = 0);
	~TreeModel();

	/***************************************************************************************************
	 * Necessary overrides for reading a tree model
	 ***************************************************************************************************/
	QVariant data(const QModelIndex &index, int role) const;
	QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const;

	QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const;
	QModelIndex parent(const QModelIndex &index) const;

	int rowCount(const QModelIndex &parent = QModelIndex()) const;
	int columnCount(const QModelIndex &parent = QModelIndex()) const;
	/***************************************************************************************************/


	/***************************************************************************************************
	 * Necessary overrides for writing a tree model
	 ***************************************************************************************************/
	Qt::ItemFlags flags(const QModelIndex &index) const;
	bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole);
	bool setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role = Qt::EditRole);

	bool insertColumns(int position, int columns, const QModelIndex &parent = QModelIndex());
	bool removeColumns(int position, int columns, const QModelIndex &parent = QModelIndex());
	bool insertRows(int position, int rows, const QModelIndex &parent = QModelIndex());
	bool removeRows(int position, int rows, const QModelIndex &parent = QModelIndex());
	/***************************************************************************************************/

    TreeItem* addItem(const TypeGroup *senderGroup, const QModelIndex &index);
	bool addItem(TreeItem *item);
	bool addItem(TreeItem *item, Node *parentItem, const QModelIndex& pIdx);
	void removeItem(const QModelIndex& idx);
    void clear() { removeItem(QModelIndex()); }
    TreeItem* createItem(const QMap<QString, QVariant>& data, Node* parent = 0);

    QTextStream& write(QTextStream& stream) const { return root->write(stream); }

    bool isDecisionTree() const { return treeType.isDecision(); }
    bool isBehaviorTree() const { return treeType.isBehavior(); }

private:
	TreeItem* get(const QModelIndex &index) const; // helper to convert model indexes to local indexes
	QModelIndex indexOf(TreeItem *item) const;

	QString getHeader(int section) const
	{
		switch (section)
		{
		case 0:
			return QString("Name");
			break;
		case 1:
            return QString("ID");
            break;
		default:
			return QString();
			break;
		};
	}

	Node* root;
    TreeType treeType;
};

#endif // TREEMODEL_H
