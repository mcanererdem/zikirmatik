package com.example.zikirmatik_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
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
            
            val intent = Intent(context, ZikrWidgetProvider::class.java)
            intent.action = "INCREMENT_COUNTER"
            val pendingIntent = PendingIntent.getBroadcast(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_increment, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == "INCREMENT_COUNTER") {
            val widgetData = HomeWidgetPlugin.getData(context)
            val counter = widgetData.getInt("counter", 0) + 1
            widgetData.edit().putInt("counter", counter).apply()
            
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val ids = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, ZikrWidgetProvider::class.java)
            )
            onUpdate(context, appWidgetManager, ids)
        }
    }
}
