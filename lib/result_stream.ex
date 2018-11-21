defmodule GithubStream.ResultStream do
  @moduledoc """
  """
  # @gateway Application.get_env(:github_stream, :gateway)

  def new(url) do
    Stream.resource(
      fn -> fetch_page(url) end,
      &process_page/1,
      fn _ -> nil end
    )
  end

  defp fetch_page(url) do
    gateway = Application.get_env(:github_stream, :gateway)
    response = gateway.get!(url)
    items = Poison.decode! response.body
    next_link = response.headers
      |> get_header_val("Link")
      |> parse_links_text()
    {items, next_link}
  end

  defp get_header_val(headers, key) do
    Enum.find_value(headers, fn {k, v} -> key == k && v end)
  end

  defp parse_links_text(links_text) do
    pattern = ~r/<.+?api.github.com(.+?\d+)>;\s*rel="(?:next)"/
    case Regex.run(pattern , links_text) do
      nil ->
        nil
      [_, next_link] ->
        next_link
    end
  end

  defp process_page({items, next_page_url}) do
    case {items, next_page_url} do
      {nil, nil} ->
        {:halt, nil}

      {nil, next_page_url} ->
        {next_items, next_link} = fetch_page(next_page_url)
        {next_items, {nil, next_link}}

      _ ->
        {items, {nil, next_page_url}}
    end
  end

  def elixir_repo_exists do
    File.exists?("./elixir_repo.json")
  end

  def stream_elixir_json do
    output_folder_str = [__DIR__, "..", "stream_elixir_json"]
    |> Path.join()
    |> Path.expand()

    Stream.resource(
      fn ->
        start_index = 1
        {start_index, File.open!("./elixir_repo.json")}
      end,
      fn {index, file} ->
        case IO.read(file, :line) do
          data when is_binary(data) ->
            out_file = output_folder_str
            |> Path.join("line-#{index}.txt")
            |> File.open!([:write])

            IO.write out_file, "line: #{index}\t: #{data}"
            File.close(out_file)

            next_index = index + 1
            {[data], {next_index, file}}
          _ ->
            {:halt, file}
        end
      end,
      fn file -> File.close(file) end
    )
  end
end
