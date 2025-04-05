defmodule Mix.Tasks.ErrorTracker.Install.Docs do
  @moduledoc false

  def short_doc do
    "Install and configure ErrorTracker for use in this application."
  end

  def example do
    "mix error_tracker.install"
  end

  def long_doc do
    """
    #{short_doc()}

    ## Example

    ```bash
    #{example()}
    ```
    """
  end
end

if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.ErrorTracker.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()}"

    @moduledoc __MODULE__.Docs.long_doc()

    use Igniter.Mix.Task

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{
        # Groups allow for overlapping arguments for tasks by the same author
        # See the generators guide for more.
        group: :error_tracker,
        # *other* dependencies to add
        # i.e `{:foo, "~> 2.0"}`
        adds_deps: [],
        # *other* dependencies to add and call their associated installers, if they exist
        # i.e `{:foo, "~> 2.0"}`
        installs: [],
        # An example invocation
        example: __MODULE__.Docs.example(),
        # A list of environments that this should be installed in.
        only: nil,
        # a list of positional arguments, i.e `[:file]`
        positional: [],
        # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
        # This ensures your option schema includes options from nested tasks
        composes: [],
        # `OptionParser` schema
        schema: [],
        # Default values for the options in the `schema`
        defaults: [],
        # CLI aliases
        aliases: [],
        # A list of options in the schema that are required
        required: []
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      app_name = Igniter.Project.Application.app_name(igniter)
      repo_module = Igniter.Project.Module.module_name(igniter, "Repo")
      web_module = Igniter.Libs.Phoenix.web_module(igniter)

      igniter
      |> configure(app_name, repo_module)
      |> set_up_database(repo_module)
      |> set_up_web_ui(web_module)
    end

    defp configure(igniter, app_name, repo_module) do
      igniter
      |> Igniter.Project.Config.configure("config.exs", :error_tracker, [:repo], repo_module)
      |> Igniter.Project.Config.configure("config.exs", :error_tracker, [:otp_app], app_name)
      |> Igniter.Project.Config.configure("config.exs", :error_tracker, [:enabled], true)
    end

    defp set_up_database(igniter, repo_module) do
      migration_body = """
      def up, do: ErrorTracker.Migration.up()
      def down, do: ErrorTracker.Migration.down(version: 1)
      """

      Igniter.Libs.Ecto.gen_migration(igniter, repo_module, "add_error_tracker",
        body: migration_body,
        on_exists: :skip
      )
    end

    defp set_up_web_ui(igniter, web_module) do
      content =
        """
        # TODO: This path should be protected from unauthorized user access
        error_tracker_dashboard "/errors"
        """

      Igniter.Libs.Phoenix.append_to_scope(igniter, "/", content, arg2: web_module)
    end
  end
else
  defmodule Mix.Tasks.ErrorTracker.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()} | Install `igniter` to use"

    @moduledoc __MODULE__.Docs.long_doc()

    use Mix.Task

    def run(_argv) do
      Mix.shell().error("""
      The task 'error_tracker.install' requires igniter. Please install igniter and try again.

      For more information, see: https://hexdocs.pm/igniter/readme.html#installation
      """)

      exit({:shutdown, 1})
    end
  end
end
