class Response < ApplicationRecord

    belongs_to :answer_choice,
        class_name: 'AnswerChoice',
        foreign_key: :answer_choice_id,
        primary_key: :id

    belongs_to :respondent,
        class_name: 'User',
        foreign_key: :user_id,
        primary_key: :id

    has_one :question, through: :answer_choice, source: :question


    validate :not_duplicate_response, unless: -> {answer_choice.nil?}
    validate :respondent_is_not_poll_author, unless: -> {answer_choice.nil?}

    def sibling_responses
        self.question.responses.where.not(id: self.id)
    end

    def respondent_already_answered?
        self.sibling_responses.where(user_id: self.user_id).exists?
    end



    private

    def not_duplicate_response
        if respondent_already_answered?
            errors[:user_id] << 'cannot vote twice for question'
        end
    end

    def respondent_is_not_poll_author
        poll_author_id = Poll
        .joins(questions: :answer_choices)
        .where('answer_choices.id = ?', self.answer_choice_id)
        .pluck('polls.user_id')
        .first
  
      if poll_author_id == self.user_id
        errors[:user_id] << 'cannot be poll author'
      end
    end
end
