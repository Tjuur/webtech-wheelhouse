class RepairPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.owner? || user&.counter? || own_repair?
  end

  def create?
    user.owner? || user&.counter?
  end

  def update?
    return true if user&.owner?
    return false if handed_back?

    user&.counter? || own_repair?
  end

  def destroy?
    user&.owner?
  end

  def destroy_intake_photo?
    user&.owner? || (user&.counter? && !handed_back?)
  end

  def permitted_attributes
    if user.mechanic?
      [
        :status,
        :diagnosis,
        { intake_photos: [] }
      ]
    else
      [
        :bike_id,
        :staff_id,
        :status,
        :approval_status,
        :promised_on,
        :quoted_at,
        :handed_back_at,
        :diagnosis,
        { intake_photos: [] },
        {
          repair_services_attributes: [
            :id,
            :service_id,
            :charged_price,
            :_destroy
          ]
        }
      ]
    end
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.owner? || user&.counter?

      if user&.mechanic? && user.staff_id.present?
        scope.where(staff_id: user.staff_id)
      else
        scope.none
      end
    end
  end

  private

  def own_repair?
    user&.mechanic? &&
      user.staff_id.present? &&
      record.staff_id == user.staff_id
  end

  def handed_back?
    record.picked_up? || record.handed_back_at.present?
  end
end
