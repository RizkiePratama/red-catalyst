class EmbedStream < ActiveRecord::Base
    validates :url, uniqueness: true
    validates :url, presence: true
    validates :name, uniqueness: true
    validates :name, presence: true
    validates :sname, uniqueness: true
    validates :sname, presence: true
end