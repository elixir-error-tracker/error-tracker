# ErrorTracker

An Elixir based built-in error tracking solution.

<a href="guides/screenshots/error-dashboard.png">
  <img src="guides/screenshots/error-dashboard.png" alt="ErrorTracker web dashboard" width="400">
</a>
<a href="guides/screenshots/error-detail.png">
  <img src="guides/screenshots/error-detail.png" alt="ErrorTracker error detail" width="400">
</a>

## Configuration

Take a look at the [Getting Started](/guides/Getting%20Started.md) guide.

## Development

### Development server

We have a `dev.exs` script that starts a development server.

To run it together with an `IEx` console you can do:

```
iex -S mix dev
```

### Assets

In order to participate in the development of this library, you may need to
know how to compile the assets needed to use the Web UI.

To do so, you need to first make a clean build:

```
mix do assets.install, assets.build
```

That task will build the JS and CSS of the project.

The JS is not expected to change too much because we rely in LiveView, but if
you make any change just execute that command again and you are good to go.

In the case of CSS, as it is automatically generated by Tailwind, you need to
start the watcher when your intention is to modify the classes used.

To do so you can execute this task in a separate terminal:

```
mix assets.watch
```
