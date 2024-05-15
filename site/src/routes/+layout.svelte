<script>
	import './base.css';
	import './fonts.css';
	import icon from "$lib/images/Icon.webp";
</script>

<div class="app">
	<header>
		<div>
		<a href="https://www.tomschamberger.com/">
			<img src={icon}
				 alt="TS Icon"
			/>
		</a>
		</div>
	</header>

	<main>
		<slot />
	</main>

	<footer>
		My footer
	</footer>
</div>

<style>
	.app {
		display: flex;
		flex-direction: column;
		min-height: 100vh;
	}

	header {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		padding: 12px;
	}

	header div {
		height: 50px;
	}

	main {
		flex: 1;
		display: flex;
		flex-direction: column;
		padding: 1rem;
		width: 100%;
		max-width: 64rem;
		margin: 0 auto;
		box-sizing: border-box;
	}

	footer {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		padding: 12px;
	}

	@media (min-width: 480px) {
		footer {
			padding: 12px 0;
		}
	}
</style>
