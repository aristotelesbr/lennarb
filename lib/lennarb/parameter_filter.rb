module Lennarb
  # Filtra parâmetros sensíveis de logs e exceções.
  # Útil para evitar o vazamento de informações confidenciais.
  #
  # Por padrão, as seguintes chaves de parâmetros são filtradas:
  #
  # - `passw`
  # - `email`
  # - `secret`
  # - `token`
  # - `_key`
  # - `crypt`
  # - `salt`
  # - `certificate`
  # - `otp`
  # - `ssn`
  # - `cvv`
  # - `cvc`
  # - `signature`
  #
  # @example
  #   filter = Lennarb::ParameterFilter.new
  #   filter.filter({ password: "secret", user: { email: "test@example.com" } })
  #   # => { password: "[filtered]", user: { email: "[filtered]" } }
  #
  class ParameterFilter
    # @api private
    DEFAULT_MASK = "[FILTERED]"

    # @api private
    DEFAULT_FILTERS = %w[
      passw email secret token _key crypt salt certificate otp ssn cvv cvc
      signature
    ].freeze

    # Inicializa um novo filtro de parâmetros
    #
    # @param [Array<String, Regexp>] filters Lista de padrões para filtrar
    def initialize(filters = DEFAULT_FILTERS)
      @filter = Regexp.union(filters.map(&:to_s))
    end

    # Filtra os parâmetros conforme o filtro configurado
    #
    # @param [Hash, Array] params Parâmetros a serem filtrados
    # @param [String] mask Valor que substituirá os parâmetros filtrados
    # @return [Hash, Array] Parâmetros filtrados
    def filter(params, mask: DEFAULT_MASK)
      filter_object(params.dup, mask)
    end

    private

    # Filtra recursivamente um objeto (hash ou array)
    #
    # @param [Object] object Objeto a ser filtrado
    # @param [String] mask Valor que substituirá os parâmetros filtrados
    # @return [Object] Objeto filtrado
    def filter_object(object, mask)
      case object
      when Hash
        object.each do |key, value|
          object[key] = if key.to_s.match?(@filter)
            mask
          else
            filter_object(value, mask)
          end
        end
      when Array
        object = object.map { filter_object(it, mask) }
      end

      object
    end
  end
end
