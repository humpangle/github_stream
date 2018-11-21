defmodule GithubStream.Gateway do
  @moduledoc """
  Documentation for GithubStream.
  """

  use HTTPoison.Base

  @endpoint "https://api.github.com"

  def endpoint do
    @endpoint
  end

  defp process_url(url) do
    @endpoint <> url
  end
end
