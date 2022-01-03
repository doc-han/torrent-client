defmodule Torrent.TableFormatter do
  @moduledoc """
    Provides functions for formatting response data into table format
  
    print_table_for_columns(response, _, true)
                      Entry point for response to begin formatting
    split_into_columns(rows, headers)
                      Splits data in rows by headers
    printable(str)    Generates printable values by returning string equivalents of passed data
                      cleaning up certain options
    widths_of(columns)
                      Retrieves maximum width of columns from their data
    format_for(column_widths)
                      Sets format for each column by its column width and data entries
    puts_in_columns(data_by_columns, format)
  
  """
  import Enum, only: [each: 2, map: 2, map_join: 3, max: 1]
  @headers Application.get_env(:torrent_client, :headers)

  def print_table_for_columns(response, _, true),
    do: response |> IO.inspect()

  @doc """
    Entry point for response to begin formatting
  
    Takes in rows and headers and displays data in a structure
  """
  def print_table_for_columns(rows, headers \\ @headers) do
    with data_by_columns = split_into_columns(rows, headers),
         column_widths = widths_of(data_by_columns),
         format = format_for(column_widths) do
      puts_one_line_in_columns(headers, format)
      IO.puts(separator(column_widths))
      puts_in_columns(data_by_columns, format)
    end
  end

  defp split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows, do: printable(Map.get(row, header))
    end
  end

  defp printable(str) when is_binary(str), do: str
  defp printable(str), do: to_string(str)

  defp widths_of(columns) do
    for column <- columns, do: column |> map(&String.length/1) |> max
  end

  defp format_for(column_widths) do
    map_join(column_widths, " | ", fn width -> "~-#{width}s" end) <> "~n"
  end

  defp separator(column_widths) do
    map_join(column_widths, "-+-", fn width -> List.duplicate("-", width) end)
  end

  defp puts_in_columns(data_by_columns, format) do
    data_by_columns
    |> List.zip()
    |> map(&Tuple.to_list/1)
    |> each(&puts_one_line_in_columns(&1, format))
  end

  defp puts_one_line_in_columns(fields, format) do
    :io.format(format, fields)
  end
end
