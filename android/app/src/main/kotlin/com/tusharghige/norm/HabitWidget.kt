package com.tusharghige.norm

import android.content.Context
import android.util.Log
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.currentState
import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import androidx.glance.layout.*
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.text.FontWeight
import androidx.glance.appwidget.cornerRadius
import androidx.glance.action.clickable
import androidx.glance.action.actionStartActivity
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.unit.ColorProvider
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import org.json.JSONObject

class HabitWidget : GlanceAppWidget() {

    companion object {
        private const val TAG = "HabitWidget"
    }

    // CRITICAL: Required for home_widget to update the widget
    // See: https://docs.page/abausg/home_widget/setup/android
    override val stateDefinition: GlanceStateDefinition<*>
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        Log.d(TAG, "provideGlance called - widget is refreshing")
        provideContent {
            WidgetContent(context, currentState())
        }
    }

    @Composable
    private fun WidgetContent(context: Context, currentState: HomeWidgetGlanceState) {
        // Load data from home_widget state (managed by HomeWidgetGlanceStateDefinition)
        val data = loadWidgetData(context, currentState)
        Log.d(TAG, "WidgetContent recomposing with data: ${data != null}")
        
        Column(
            modifier = GlanceModifier
                .fillMaxWidth()
                .background(ColorProvider(androidx.compose.ui.graphics.Color.Black))
                .cornerRadius(16.dp)
                .padding(16.dp)
                .clickable(actionStartActivity<MainActivity>())
        ) {
            if (data != null) {
                val habits = data.optJSONArray("habits")
                val days = data.optJSONArray("days")

                if (habits != null && days != null) {
                    // Day labels row
                    Row(
                        modifier = GlanceModifier
                            .fillMaxWidth()
                            .padding(bottom = 8.dp)
                    ) {
                        // Empty space for habit names (fixed width to match habit names below)
                        Spacer(modifier = GlanceModifier.width(90.dp))
                        
                        // Small spacer to match habit row
                        Spacer(modifier = GlanceModifier.width(8.dp))
                        
                        // Day labels (takes remaining space)
                        Row(
                            modifier = GlanceModifier.defaultWeight(),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            for (i in 0 until 7) {
                                if (i < days.length()) {
                                    val day = days.getJSONObject(i)
                                    val label = day.getString("label")
                                    val isToday = day.getBoolean("isToday")
                                    
                                    Box(
                                        modifier = GlanceModifier.defaultWeight(),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Text(
                                            text = label,
                                            style = TextStyle(
                                                color = ColorProvider(
                                                    if (isToday) 
                                                        androidx.compose.ui.graphics.Color(0xFFa7e3fb) 
                                                    else 
                                                        androidx.compose.ui.graphics.Color(0x66808080)
                                                ),
                                                fontSize = 14.sp,
                                                fontWeight = FontWeight.Bold
                                            )
                                        )
                                    }
                                }
                            }
                        }
                    }

                    // Habits list (scrollable - no limit, all habits shown)
                    LazyColumn(
                        modifier = GlanceModifier.fillMaxWidth().defaultWeight()
                    ) {
                        val habitCount = habits.length() // Show all habits
                        
                        items(habitCount) { habitIndex ->
                            val habit = habits.getJSONObject(habitIndex)
                            HabitRow(habit)
                        }
                    }
                } else {
                    EmptyState("No habits yet\nTap to open app")
                }
            } else {
                EmptyState("No data yet\nOpen app to sync")
            }
        }
    }

    @Composable
    private fun HabitRow(habit: JSONObject) {
        val habitId = habit.getString("id")
        val name = habit.getString("name")
        val colorInt = habit.getInt("color")
        val completions = habit.getJSONArray("completions")
        
        Row(
            modifier = GlanceModifier
                .fillMaxWidth()
                .padding(vertical = 2.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Habit name (fixed width ~30% of typical widget)
            Box(
                modifier = GlanceModifier.width(90.dp),
                contentAlignment = Alignment.CenterStart
            ) {
                Text(
                    text = name,
                    style = TextStyle(
                        color = ColorProvider(androidx.compose.ui.graphics.Color.White),
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium
                    ),
                    maxLines = 1
                )
            }
            
            // Small spacer
            Spacer(modifier = GlanceModifier.width(8.dp))
            
            // Completion indicators (takes remaining space, ~70%)
            Row(
                modifier = GlanceModifier.defaultWeight(),
                horizontalAlignment = Alignment.End,
                verticalAlignment = Alignment.CenterVertically
            ) {
                for (i in 0 until 7) {
                    val isCompleted = if (i < completions.length()) {
                        completions.getBoolean(i)
                    } else {
                        false
                    }
                    
                    Box(
                        modifier = GlanceModifier
                            .defaultWeight()
                            .padding(4.dp), // Add padding around click area
                        contentAlignment = Alignment.Center
                    ) {
                        // Fixed size container for consistent click area with rounded ripple
                        Box(
                            modifier = GlanceModifier
                                .size(24.dp)
                                .cornerRadius(12.dp) // Rounded click ripple
                                .clickable(
                                    onClick = actionRunCallback<ToggleHabitAction>(
                                        parameters = actionParametersOf(
                                            ActionParameters.Key<String>("habitId") to habitId,
                                            ActionParameters.Key<Int>("dayIndex") to i
                                        )
                                    )
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            CompletionIndicator(
                                isCompleted = isCompleted,
                                color = androidx.compose.ui.graphics.Color(colorInt)
                            )
                        }
                    }
                }
            }
        }
    }

    @Composable
    private fun CompletionIndicator(isCompleted: Boolean, color: androidx.compose.ui.graphics.Color) {
        val size = if (isCompleted) 18.dp else 8.dp
        val radius = if (isCompleted) 4.dp else 10.dp
        val alpha = if (isCompleted) 1f else 0.4f
        
        Box(
            modifier = GlanceModifier
                .size(size)
                .background(ColorProvider(color.copy(alpha = alpha)))
                .cornerRadius(radius),
            content = {}
        )
    }

    @Composable
    private fun EmptyState(message: String) {
        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(top = 24.dp),
            contentAlignment = Alignment.TopCenter
        ) {
            Text(
                text = message,
                style = TextStyle(
                    color = ColorProvider(androidx.compose.ui.graphics.Color(0xFF808080)),
                    fontSize = 13.sp
                )
            )
        }
    }

    private fun loadWidgetData(context: Context, currentState: HomeWidgetGlanceState): JSONObject? {
        return try {
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            val json = prefs.getString("habits_data", null)
            
            Log.d(TAG, "=== Loading widget data ===")
            Log.d(TAG, "Data length: ${json?.length ?: 0}")
            Log.d(TAG, "Timestamp: ${System.currentTimeMillis()}")
            
            if (json != null) {
                val data = JSONObject(json)
                val habits = data.optJSONArray("habits")
                val days = data.optJSONArray("days")
                val timestamp = data.optLong("timestamp", 0)
                
                Log.d(TAG, "Parsed ${habits?.length() ?: 0} habits")
                Log.d(TAG, "Parsed ${days?.length() ?: 0} days")
                Log.d(TAG, "Data timestamp: $timestamp")
                
                // Log all habit names for debugging
                if (habits != null && habits.length() > 0) {
                    Log.d(TAG, "Habit names:")
                    for (i in 0 until habits.length()) {
                        val habit = habits.getJSONObject(i)
                        Log.d(TAG, "  ${i + 1}. ${habit.getString("name")}")
                    }
                }
                
                Log.d(TAG, "=== Widget data loaded successfully ===")
                data
            } else {
                Log.w(TAG, "No widget data found in shared preferences")
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error loading widget data", e)
            null
        }
    }
}

/**
 * Action callback to handle habit completion toggles from the widget
 */
class ToggleHabitAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val habitId = parameters[ActionParameters.Key<String>("habitId")]
        val dayIndex = parameters[ActionParameters.Key<Int>("dayIndex")]
        
        Log.d("ToggleHabitAction", "Toggle habit: $habitId, day: $dayIndex")
        
        if (habitId != null && dayIndex != null) {
            // Send broadcast to Flutter to toggle the habit
            val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("norm://toggleHabit?habitId=$habitId&dayIndex=$dayIndex")
            )
            backgroundIntent.send()
            
            Log.d("ToggleHabitAction", "Broadcast sent to toggle habit")
        }
    }
}
