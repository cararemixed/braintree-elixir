defmodule Braintree.Customer do
  @moduledoc """
  You can create a customer by itself, with a payment method, or with a
  credit card with a billing address.

  For additional reference see:
  https://developers.braintreepayments.com/reference/request/customer/create/ruby
  """

  use Braintree.Construction

  alias Braintree.{AndroidPayCard, ApplePayCard, CreditCard, HTTP, PaypalAccount, Search, UsBankAccount}
  alias Braintree.ErrorResponse, as: Error

  @type t :: %__MODULE__{
          id: String.t(),
          company: String.t(),
          email: String.t(),
          fax: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          phone: String.t(),
          website: String.t(),
          created_at: String.t(),
          updated_at: String.t(),
          custom_fields: map,
          addresses: [map],
          android_pay_cards: [AndroidPayCard.t()],
          apple_pay_cards: [ApplePayCard.t()],
          credit_cards: [CreditCard.t()],
          paypal_accounts: [PaypalAccount.t()],
          coinbase_accounts: [map],
          us_bank_accounts: [UsBankAccount.t()]
        }

  defstruct id: nil,
            company: nil,
            email: nil,
            fax: nil,
            first_name: nil,
            last_name: nil,
            phone: nil,
            website: nil,
            created_at: nil,
            updated_at: nil,
            custom_fields: %{},
            addresses: [],
            android_pay_cards: [],
            apple_pay_cards: [],
            credit_cards: [],
            coinbase_accounts: [],
            paypal_accounts: [],
            us_bank_accounts: []

  @doc """
  Create a customer record, or return an error response with after failed
  validation.

  ## Example

      {:ok, customer} = Braintree.Customer.create(%{
        first_name: "Jen",
        last_name: "Smith",
        company: "Braintree",
        email: "jen@example.com",
        phone: "312.555.1234",
        fax: "614.555.5678",
        website: "www.example.com"
      })

      customer.company # Braintree
  """
  @spec create(map, Keyword.t()) :: {:ok, t} | {:error, Error.t()}
  def create(params \\ %{}, opts \\ []) do
    with {:ok, payload} <- HTTP.post("customers", %{customer: params}, opts) do
      {:ok, new(payload)}
    end
  end

  @doc """
  You can delete a customer using its ID. When a customer is deleted, all
  associated payment methods are also deleted, and all associated recurring
  billing subscriptions are canceled.

  ## Example

      :ok = Braintree.Customer.delete("customer_id")
  """
  @spec delete(binary, Keyword.t()) :: :ok | {:error, Error.t()}
  def delete(id, opts \\ []) when is_binary(id) do
    with {:ok, _response} <- HTTP.delete("customers/" <> id, opts) do
      :ok
    end
  end

  @doc """
  If you want to look up a single customer using its ID, use the find method.

  ## Example

      customer = Braintree.Customer.find("customer_id")
  """
  @spec find(binary, Keyword.t()) :: {:ok, t} | {:error, Error.t()}
  def find(id, opts \\ []) when is_binary(id) do
    with {:ok, payload} <- HTTP.get("customers/" <> id, opts) do
      {:ok, new(payload)}
    end
  end

  @doc """
  To update a customer, use its ID along with new attributes. The same
  validations apply as when creating a customer. Any attribute not passed will
  remain unchanged.

  ## Example

      {:ok, customer} = Braintree.Customer.update("customer_id", %{
        company: "New Company Name"
      })

      customer.company # "New Company Name"
  """
  @spec update(binary, map, Keyword.t()) :: {:ok, t} | {:error, Error.t()}
  def update(id, params, opts \\ []) when is_binary(id) and is_map(params) do
    with {:ok, payload} <- HTTP.put("customers/" <> id, %{customer: params}, opts) do
      {:ok, new(payload)}
    end
  end

  @doc """
  To search for customers, pass a map of search parameters.


  ## Example:

      {:ok, customers} = Braintree.Customer.search(%{first_name: %{is: "Jenna"}})
  """
  @spec search(map, Keyword.t()) :: {:ok, t} | {:error, Error.t()}
  def search(params, opts \\ []) when is_map(params) do
    Search.perform(params, "customers", &new/1, opts)
  end

  @doc """
  Convert a map into a Company struct along with nested payment options. Credit
  cards and paypal accounts are converted to a list of structs as well.

  ## Example

      customer = Braintree.Customer.new(%{"company" => "Soren",
                                          "email" => "parker@example.com"})
  """
  def new(%{"customer" => map}) do
    new(map)
  end

  def new(map) when is_map(map) do
    customer = super(map)

    %{
      customer
      | android_pay_cards: AndroidPayCard.new(customer.android_pay_cards),
        apple_pay_cards: ApplePayCard.new(customer.apple_pay_cards),
        credit_cards: CreditCard.new(customer.credit_cards),
        paypal_accounts: PaypalAccount.new(customer.paypal_accounts),
        us_bank_accounts: UsBankAccount.new(customer.us_bank_accounts)
    }
  end

  def new(list) when is_list(list) do
    Enum.map(list, &new/1)
  end
end
