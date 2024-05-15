<script>

import {page} from "$app/stores";
</script>

<svelte:head>
	<title>Home</title>
	<meta name="description" content="Svelte demo app" />
</svelte:head>

<section>
	<h1>
		Tom Schamberger
	</h1>
	<h2>
		Real-time analytics and
		event-based systems
		in the cloud
	</h2>
	<p>
		Currently working for <a href="#todo">msg</a>
	</p>
	<nav>
		<ul>
			<li aria-current={$page.url.pathname === '/' ? 'page' : undefined}>
				<a href="/">Home</a>
			</li>
			<li aria-current={$page.url.pathname === '/about' ? 'page' : undefined}>
				<a href="/about">About</a>
			</li>
		</ul>
	</nav>
</section>

<style>

	section {
		margin-top: 2rem;
	}

	h1 {
		font-family: "LeagueSpartan", sans-serif;
		font-weight: 800;
		font-size: 4rem;
		margin-bottom: 0.5rem;
	}

	h2 {
		font-family: "OpenSansSemiCondensed", sans-serif;
		font-weight: 500;
		font-size: 1.5rem;
	}

	p {
		font-family: "OpenSans", sans-serif;
		font-weight: 500;
	}
</style>
