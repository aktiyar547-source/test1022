package androidx.navigation.compose
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.*
@Composable fun rememberNavController(): NavHostController = NavHostController()
@Composable fun NavHost(navController: NavController, startDestination: String,
    modifier: Modifier = Modifier, builder: NavGraphBuilder.() -> Unit) {}
fun NavGraphBuilder.composable(route: String, arguments: List<NamedNavArgument> = emptyList(),
    content: @Composable (NavBackStackEntry) -> Unit) {}
