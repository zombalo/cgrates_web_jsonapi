defmodule CgratesWebJsonapi.Repo do
  use Ecto.Repo, otp_app: :cgrates_web_jsonapi
  use Scrivener, page_size: 10
end
