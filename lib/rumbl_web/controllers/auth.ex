defmodule RumblWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias RumblWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Rumbl.Accounts.get_user(user_id)
    assign(conn, :current_user, user) # Add the current user to the connection
  end

  def login(conn, user) do
    conn
      |> assign(:current_user, user)    # Set a value in the 'assigns' field of the Plug.Conn struct
      |> put_session(:user_id, user.id) # Store the userid in the session
      |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  # The authenticate function is a plug because it takes 2 params and returns the conn
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
        |> put_flash(:error, "You must be logged in to access that page")
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt()  # Use halt to stop downstream transformations
    end
  end
end
