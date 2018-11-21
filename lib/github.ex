defmodule GithubStream.Github do
  @moduledoc """
  """
  alias GithubStream.ResultStream

  @doc """
  Takes an organization name and returns a stream representing the
   organization's github api repos. E.g.

  iex> repo_stream = repos("nodejs")
    #Function<50.51599720/2 in Stream.resource/3>

  iex> repo_stream |> Map.to_list()
    [%{}, %{}]
  """
  def repos(organization) do
    ResultStream.new("/orgs/#{organization}/repos")
  end
end
