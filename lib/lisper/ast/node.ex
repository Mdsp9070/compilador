defprotocol Lisper.Ast.Node do
  @doc "Return the literal token value"
  def token_literal(node)

  @doc "Node type, can be :statement or :expression"
  def node_type(node)

  @doc "Convert node to string"
  def to_string(node)
end
