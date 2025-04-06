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
      {igniter, repo} = Igniter.Libs.Ecto.select_repo(igniter)
      {igniter, router} = Igniter.Libs.Phoenix.select_router(igniter)

      igniter
      |> configure(app_name, repo)
      |> set_up_database(repo)
      |> set_up_web_ui(app_name, router)
    end

    defp configure(igniter, app_name, repo) do
      igniter
      |> Igniter.Project.Config.configure_new("config.exs", :error_tracker, [:repo], repo)
      |> Igniter.Project.Config.configure_new("config.exs", :error_tracker, [:otp_app], app_name)
      |> Igniter.Project.Config.configure_new("config.exs", :error_tracker, [:enabled], true)
    end

    defp set_up_database(igniter, repo) do
      migration_body = """
      def up, do: ErrorTracker.Migration.up()
      def down, do: ErrorTracker.Migration.down(version: 1)
      """

      Igniter.Libs.Ecto.gen_migration(igniter, repo, "add_error_tracker",
        body: migration_body,
        on_exists: :skip
      )
    end

    defp set_up_web_ui(igniter, app_name, router) do
      if router do
        Igniter.Project.Module.find_and_update_module!(igniter, router, fn zipper ->
          zipper =
            Igniter.Code.Common.add_code(
              zipper,
              """
              if Application.compile_env(#{inspect(app_name)}, :dev_routes) do
                use ErrorTracker.Web, :router

                scope "/dev" do
                  pipe_through :browser

                  error_tracker_dashboard "/errors"
                end
              end
              """,
              placement: :after
            )

          {:ok, zipper}
        end)
      else
        Igniter.add_warning(igniter, """
        No Phoenix router found or selected. Please ensure that Phoenix is set up
        and then run this installer again with

            mix igniter.install error_tracker
        """)
      end
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
