defmodule GithubStreamTest do
  @moduledoc """
  """
  use ExUnit.Case

  alias GithubStream.ResultStream
  alias GithubStream.Gateway.ForTest

  setup do
    Application.put_env(:github_stream, :gateway, GithubStream.Gateway.ForTest)
  end

  test "ResultStream.new/1" do
    # IO.inspect Application.get_all_env(:github_stream)
      repo_stream = "nodejs"
      |> ResultStream.new()

      repo_stream_to_list = repo_stream
      |> Enum.to_list()

      test_api_response_list = ForTest.api_body_files_contents_stream()

      assert length(repo_stream_to_list) == length(test_api_response_list)

      assert List.first(repo_stream_to_list) ==
         List.first(test_api_response_list)

      assert List.last(repo_stream_to_list) ==
         List.last(test_api_response_list)
  end

end
