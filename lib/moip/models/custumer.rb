# encoding: utf-8
class Moip::Custumer < Moip::Model
	include HTTParty
	include Moip::Header

	# see http://moiplabs.github.io/assinaturas-docs/api.html#criar_cliente
	attr_accessor :code, :email, :fullname, :cpf, :phone_area_code, 
								:phone_number, :birthdate_day, :birthdate_month, 
								:birthdate_year, :address, :billing_info, :costumers

	validates :code, :email, :fullname, :cpf, :phone_area_code, 
						:phone_number, :birthdate_day, :birthdate_month, 
						:birthdate_year, :presence => true

	validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Invalid email"

	validate :validates_presence_of_address, :validates_presence_of_billing_info

	def attributes
		{
	    "code" => code,
	    "email" => email,
	    "fullname" => fullname,
	    "cpf" => cpf,
	    "phone_area_code" => phone_area_code,
	    "phone_number" => phone_number,
	    "birthdate_day" => birthdate_day,
	    "birthdate_month" => birthdate_month,
	    "birthdate_year" => birthdate_year,
	    "address" => address,
	    "billing_info" => billing_info
		}
	end

	def address= options = {}
		@address = Moip::Address.build options
	end

	def address
		@address.serializable_hash.delete_if {|key, value| value.nil? }
	end

	def billing_info= options
		if options.is_a? Hash
			@billing_info = Moip::BillingInfo.build options
		elsif options.is_a? Moip::BillingInfo
			@billing_info = Moip::BillingInfo
		end
	end

	def billing_info
		@billing_info.to_hash
	end

	def validates_presence_of_address
		self.errors.add :address, "can't be blank" and return if @address.nil?

		if @address.valid?
			true
		else
			self.errors.add :adress, @address.errors.full_messages.first
		end
	end

	def validates_presence_of_billing_info
		self.errors.add :billing_info, "can't be blank" and return if @billing_info.nil?

		if @billing_info.valid?
			true
		else
			self.errors.add :adress, @billing_info.errors.full_messages.first
		end
	end

	def custumers= hash
		@custumers = []
		hash.each do |e|
			costumer = self.class.new
			costumer.set_parameters e
			@custumers << costumer
		end
		@custumers
	end


	def load
		list = self.class.get(base_url(:customers), default_header).parsed_response
		self.costumers = list["costumers"]
	end

	# metodo que envia as informações para a API do moip e cria um novo cliente
	# see http://moiplabs.github.io/assinaturas-docs/api.html#criar_cliente
	def create
		if self.valid?
			self.class.post(base_url(:customers, :params => "new_vault=true"), default_header(self.to_json)).parsed_response
		else
			raise Exception.new "#{self.errors.first[0]} #{self.errors.first[1]}"
		end
	end
	
	def find code
		response = self.class.get(base_url(:customers, :code => code), default_header).parsed_response
		self.set_parameters response unless response.nil?
	end
	
end