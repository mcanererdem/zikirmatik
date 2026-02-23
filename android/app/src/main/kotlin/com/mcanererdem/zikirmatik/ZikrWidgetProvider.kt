package com.mcanererdem.zikirmatik

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import com.mcanererdem.zikirmatik.R

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
                val data = HomeWidgetPlugin.getData(context)
                val cur = data.getInt("counter", 0)
                val today = data.getInt("today_count", 0)
                val total = data.getInt("total_count", 0)
                data.edit()
                    .putInt("counter", cur + 1)
                    .putInt("today_count", today + 1)
                    .putInt("total_count", total + 1)
                    .apply()
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val ids = appWidgetManager.getAppWidgetIds(
                    android.content.ComponentName(context, ZikrWidgetProvider::class.java)
                )
                for (appWidgetId in ids) updateWidget(context, appWidgetManager, appWidgetId)
            }
            "RESET_COUNTER" -> {
                val data = HomeWidgetPlugin.getData(context)
                data.edit()
                    .putInt("counter", 0)
                    .putInt("today_count", 0)
                    .apply()
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val ids = appWidgetManager.getAppWidgetIds(
                    android.content.ComponentName(context, ZikrWidgetProvider::class.java)
                )
                for (appWidgetId in ids) updateWidget(context, appWidgetManager, appWidgetId)
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
        val labelToday = widgetData.getString("label_today", null) ?: "Bugün"
        val labelTotal = widgetData.getString("label_total", null) ?: "Toplam"
        val labelStreak = widgetData.getString("label_streak", null) ?: "Seri"
        val labelTitle = widgetData.getString("label_title", null) ?: "Tasbih Counter"

        val views = RemoteViews(context.packageName, R.layout.zikr_widget)
        views.setTextViewText(R.id.widget_title, labelTitle)
        views.setTextViewText(R.id.widget_counter, counter.toString())
        
        val incIntent = Intent(context, ZikrWidgetProvider::class.java).apply { action = "INCREMENT_COUNTER" }
        val incPending = PendingIntent.getBroadcast(
            context, 100, incIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_increment, incPending)

        val resetIntent = Intent(context, ZikrWidgetProvider::class.java).apply { action = "RESET_COUNTER" }
        val resetPending = PendingIntent.getBroadcast(
            context, 101, resetIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_reset, resetPending)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
