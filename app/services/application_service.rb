class ApplicationService
  def self.call(*args)
    new(*args).call
  end

  private

  def success_response(data = {})
    object = Struct.new(:success?, :errors, :data)
    object.new(true, nil, data)
  end

  def error_response(errors = [])
    object = Struct.new(:success?, :errors)
    object.new(false, errors)
  end
end
