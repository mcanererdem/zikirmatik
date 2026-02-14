package com.example.zikirmatik_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import com.example.zikirmatik.R

class ZikrWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val counter = widgetData.getInt("counter", 0)

            val views = RemoteViews(context.packageName, R.layout.zikr_widget)
            views.setTextViewText(R.id.widget_counter, counter.toString())

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
