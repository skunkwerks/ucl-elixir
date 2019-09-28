defmodule HCL.AST do
  @moduledoc """
  Process a raw AST into nodes
  """

  @doc """
  Walk an AST and transform into known nodes
  """
  def walk(ast), do: walk_ast(ast)

  def walk_ast([]), do: []

  def walk_ast([node | nodes]) do
    [parse_node(node) | walk_ast(nodes)]
  end

  def parse_node({:object, key, object}) do
    %HCL.Object{
      key: walk_key(key),
      block: parse_node(object)
    }
  end

  def parse_node({:block, expressions}) do
    walk_ast(expressions)
  end

  def parse_node({:assignment, key, value}) do
    %HCL.Value{
      key: String.to_atom(to_string(key)),
      value: parse_value(value)
    }
  end

  def parse_value({:array, expressions}), do: walk_ast(expressions)

  def parse_value({:integer, integer}), do: integer

  def parse_value({:string, strings}) do
    strings
    |> Enum.map(&to_string/1)
    |> Enum.join()
    |> unescape_quotes()
  end

  def unescape_quotes(string) do
    string
    |> String.replace("\\\"", "\"")
    |> String.replace("\\'", "'")
  end

  def walk_key(strings) do
    Enum.map(strings, fn {:string, string} ->
      String.to_atom(to_string(string))
    end)
  end
end