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
		<strong>Real-time analytics</strong>
		and
		<strong>event-based systems</strong>
		in the
		<strong>cloud</strong>
	</h2>
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

</style>
