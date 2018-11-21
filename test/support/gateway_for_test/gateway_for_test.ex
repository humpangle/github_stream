defmodule GithubStream.Gateway.ForTest do
  @moduledoc """
  """

  alias __MODULE__

  defstruct [:body, :headers]

  @api_folder "github-api-nodejs"

  def get!(url) do
    url
    |> get_page_num_from_url()
    |> get_api_response()
  end

  defp github_api_nodejs_dir do
    [__DIR__, @api_folder]
    |> Path.join()
    |> Path.expand()
  end

  defp join_file_to_github_api_nodejs_dir(file_name) do
    [github_api_nodejs_dir(), file_name]
    |> Path.join()
  end

  defp get_api_response(page_num_text) do
    link = "#{page_num_text}-link.txt"
    |> join_file_to_github_api_nodejs_dir()
    |> File.read!()

    body = "#{page_num_text}-body.json"
    |> join_file_to_github_api_nodejs_dir()
    |> File.read!()

    %ForTest{body: body, headers: [{"Link", link}]}
  end

  defp get_page_num_from_url(url) do
    case Regex.run(~r/page=(\d)$/, url) do
      nil ->
        "1"
      [_, page_num] ->
        page_num
    end
  end

  def api_body_files_contents_stream do
    github_api_nodejs_dir()
    |> File.ls!()
    |> Enum.filter(fn name -> String.contains?(name, "body.json") end)
    |> Stream.flat_map(fn name ->
        name
        |> join_file_to_github_api_nodejs_dir()
        |> File.read!()
        |> Poison.decode!()
      end)
    |> Enum.to_list()
  end
end
