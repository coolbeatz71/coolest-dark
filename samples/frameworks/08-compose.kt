package frameworktour.compose

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Jetpack Compose framework tour.
 *
 * Covers composable functions, state hoisting, modifiers,
 * remember/derivedStateOf, previews and view models.
 */

/** UI state for the card. */
data class ArticleUiState(
    val title: String = "",
    val subtitle: String? = null,
    val likeCount: Int = 0,
    val isBookmarked: Boolean = false,
)

class ArticleViewModel : ViewModel() {
    private val _state = MutableStateFlow(ArticleUiState())
    val state: StateFlow<ArticleUiState> = _state.asStateFlow()

    fun like() {
        _state.value = _state.value.copy(likeCount = _state.value.likeCount + 1) // inline comment
    }
}

/**
 * Renders a single article card.
 *
 * @param state the immutable UI state
 * @param onLike invoked when the like button is tapped
 * @param modifier applied to the root surface
 */
@Composable
fun ArticleCard(
    state: ArticleUiState,
    onLike: () -> Unit,
    modifier: Modifier = Modifier,
) {
    var expanded by remember { mutableStateOf(false) }
    val label by remember(state.likeCount) {
        derivedStateOf { if (state.likeCount > 0) "${state.likeCount} likes" else "No likes yet" }
    }

    Surface(
        modifier = modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp),
        shape = MaterialTheme.shapes.medium,
        tonalElevation = 2.dp,
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Text(
                text = state.title,
                style = MaterialTheme.typography.titleLarge,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )

            state.subtitle?.let { subtitle ->
                Text(text = subtitle, style = MaterialTheme.typography.bodySmall)
            }

            Row(
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text(label)
                IconButton(onClick = onLike) { Text(if (state.isBookmarked) "★" else "☆") }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun ArticleCardPreview() {
    MaterialTheme {
        ArticleCard(state = ArticleUiState(title = "Hello", likeCount = 3), onLike = {})
    }
}
