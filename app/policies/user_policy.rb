class UserPolicy
  attr_reader :current_user, :model

  def initialize(current_user, user_instance)
    @current_user = current_user
    @user_instance = user_instance
  end

  def index?
    @current_user.is_assessor?
  end

  def show?
    @current_user.is_admin? or @current_user == @user_instance
  end

  def update?
    @current_user.is_admin?
  end

  def destroy?
    return false if @current_user == @user_instance
    @current_user.is_admin?
  end

end
