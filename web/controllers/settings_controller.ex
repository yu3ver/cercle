defmodule CercleApi.SettingsController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Company, Tag}

  def team_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company_id = user.company_id
    company = Repo.get!(Company, company_id) |> Repo.preload [:users]

    conn
    |> put_layout("adminlte.html")
    |> render "team_edit.html", company: company
  end

  def remove_team_member(conn, %{"user_id" => user_id}) do
    user = Guardian.Plug.current_resource(conn)

    if user.id != String.to_integer(user_id) do
      team_member = Repo.get_by(User, id: user_id, company_id: user.company_id)
      changeset = User.changeset(team_member, %{company_id: nil})
      case Repo.update(changeset) do
        {:ok, team_member} ->
          conn
          |> put_flash(:success, "Team member removed successfully")
        {:error, changeset} ->
          conn
          |> put_flash(:error, "Unable to remove team member")
      end
    end

    conn
    |> redirect(to: "/settings/team_edit")
  end

  def fields_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company_id = user.company_id
    company = Repo.get!(Company, company_id)
    changeset = Company.changeset(company)

    conn
    |> put_layout("adminlte.html")
    |> render "fields_edit.html", company: company, changeset: changeset, settings: true
  end

  def tags_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.get(Company, user.company_id)
    query = from t in Tag,
      where: t.company_id == ^company.id,
      order_by: [desc: t.inserted_at]
    tags = Repo.all(query)
    conn
    |> put_layout("adminlte.html")
    |> render "tags_edit.html", tags: tags
  end

  def api_key(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.get(Company, user.company_id)
    conn
    |> put_layout("adminlte.html")
    |> render "api_key.html", company: company
  end

  def team_invitation(conn, %{"user" => user_params}) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.get!(Company, user.company_id)
    receiver_email = user_params["email"]
    values = %{"company_id": "#{company.id}", "email": "#{receiver_email}"}
    encoded_values = URI.encode(Cipher.cipher(values))
    try do
      CercleApi.Mailer.deliver invitation_email(user, receiver_email, company.title, encoded_values)
      conn
      |> put_flash(:success, "Invitation link sent successfully!")
      |> redirect(to: "/settings/team_edit")
    rescue RuntimeError ->
      conn
      |> put_flash(:error, "Unable to send invitation link due to some error!")
      |> redirect(to: "/settings/team_edit")
    end
  end

  def invitation_email(sender, receiver_email, company_name, encoded_values) do
    %Mailman.Email{
      subject: sender.user_name <> " invited to join " <> company_name,
      from: "referral@cercle.co",
      to: [receiver_email],
      html: Phoenix.View.render_to_string(CercleApi.EmailView, "team_invitation.html", sender: sender, receiver_email: receiver_email, company_name: company_name, encoded_values: encoded_values)
      }
  end

  def webhooks(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    if user.company_id do
      company = Repo.get(Company, user.company_id)
    end

    conn
    |> put_layout("adminlte.html")
    |> render("webhooks.html", company: company, user: user)
  end
end
