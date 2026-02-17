package com.example.zikirmatik

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
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        when (intent.action) {
            "INCREMENT_COUNTER" -> {
                val widgetData = HomeWidgetPlugin.getData(context)
                val currentCounter = widgetData.getInt("counter", 0)
                val newCounter = currentCounter + 1
                widgetData.edit().putInt("counter", newCounter).apply()
                
                // Update widget display
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val ids = appWidgetManager.getAppWidgetIds(
                    android.content.ComponentName(context, ZikrWidgetProvider::class.java)
                )
                for (appWidgetId in ids) {
                    updateWidget(context, appWidgetManager, appWidgetId)
                }
            }
            "RESET_COUNTER" -> {
                val widgetData = HomeWidgetPlugin.getData(context)
                widgetData.edit().putInt("counter", 0).apply()
                
                // Update widget display
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val ids = appWidgetManager.getAppWidgetIds(
                    android.content.ComponentName(context, ZikrWidgetProvider::class.java)
                )
                for (appWidgetId in ids) {
                    updateWidget(context, appWidgetManager, appWidgetId)
                }
            }
        }
    }
    
    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val counter = widgetData.getInt("counter", 0)
        val todayCount = widgetData.getInt("today_count", 0)
        val totalCount = widgetData.getInt("total_count", 0)
        val streak = widgetData.getInt("streak", 0)

        val views = RemoteViews(context.packageName, R.layout.zikr_widget)
        views.setTextViewText(R.id.widget_counter, counter.toString())
        views.setTextViewText(R.id.widget_today_count, todayCount.toString())
        views.setTextViewText(R.id.widget_total, totalCount.toString())
        views.setTextViewText(R.id.widget_streak, streak.toString())
        
        val incrementIntent = Intent(context, ZikrWidgetProvider::class.java)
        incrementIntent.action = "INCREMENT_COUNTER"
        val incrementPendingIntent = PendingIntent.getBroadcast(
            context, 0, incrementIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_increment, incrementPendingIntent)
        
        val resetIntent = Intent(context, ZikrWidgetProvider::class.java)
        resetIntent.action = "RESET_COUNTER"
        val resetPendingIntent = PendingIntent.getBroadcast(
            context, 1, resetIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_reset, resetPendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
