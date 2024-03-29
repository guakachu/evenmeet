class RelationshipsController < ApplicationController
  before_action :set_current_participation
  before_action :set_event
  before_action :set_target_participation, only: %i[create]

  def new
    @all_participations = @event.participations
    @sender_matches     = @current_participation.sender_relationships.map { |relation| relation.receiver }
    @receiver_matches   = @current_participation.receiver_relationships.map { |relation| relation.sender unless relation.pending? }
    @participations = @all_participations - @sender_matches - @receiver_matches
    @participations = @participations.reject! { |participation| participation.user == current_user }
    
    @participations = @participations.select { |p| p.user.first_name == "Laura" ||
                                                   p.user.first_name == "Paul" ||
                                                   p.user.first_name == "Marie" ||
                                                   p.user.first_name == "Thomas"}
  end

  def create
    relation = find_or_create_relationship

    if liked?
      # New relationship => on en fait rien
      # Relation existante en refused => on ne fait rien
      # Relation existante en pending => accepted!
      if relation.pending? && relation.receiver == @current_participation
        relation.accepted!
        @challenge = Challenge.new
        @challenge.relationship = relation
        @challenge.reward = Reward.all.sample
        @challenge.save
        initialize_messages(@challenge)
      end
    else
      # New relationship => refused!
      # Relationship existante => refused!
      relation.refused! unless liked?
    end

    if relation.accepted?
      respond_to do |format|
        # format.json { render(json: { content: "You matched with #{@target_participation.user.first_name}" }) }
        format.json { render(json: { content: render_to_string(partial: "relationships/match", locals: { target: @target_participation, current: @current_participation, challenge: @challenge}, formats: :html) }) }
        format.html {
          redirect_to root_path, status: :see_other, notice: "You matched with #{@target_participation.user.first_name}"
        }
      end
    else
      respond_to do |format|
        format.json { render(json: { status: relation.status }) }
        format.html { redirect_to root_path, status: :see_other, notice: "" }
      end
    end
  end

  private

  def set_current_participation
    @current_participation = Participation.find(params[:participation_id])
  end

  def set_event
    @event = @current_participation.event
  end

  def set_target_participation
    @target_participation = Participation.find(params[:id])
  end

  def find_or_create_relationship
    # On regarde si une relation existe déjà
    @current_participation.receiver_relationships.each do |relationship|
      if relationship.sender == @target_participation
        # match existe déjà, on retourne la relation
        return relationship
      end
    end

    # Sinon, on initialise le match
    create_relationship(@current_participation, @target_participation)
  end

  def create_relationship(current_participation, target_participation)
    relationship = Relationship.new
    relationship.sender   = current_participation
    relationship.receiver = target_participation
    relationship.save
    return relationship
  end

  def liked?
    params[:liked] == true
  end

  def initialize_messages(current_challenge)
    sender = current_challenge.relationship.sender
    receiver = current_challenge.relationship.receiver
    Message.create(challenge: current_challenge,
                   user: sender.user,
                   content: "Hey #{receiver.user.first_name}, my hint is #{current_challenge.relationship.sender.hint}")
    Message.create(challenge: current_challenge,
                   user: receiver.user,
                   content: "Hey #{sender.user.first_name}, my hint is #{current_challenge.relationship.receiver.hint}")
  end
end
