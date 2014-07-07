require 'rails_helper'

RSpec.describe Post, :type => :model do
  describe '#sha' do
    it 'is automatically generated when validating a post instance' do
      post = build(:post)
      expect(post.sha).to be_blank
      post.valid?
      expect(post.sha).to_not be_blank
    end
  end

  context 'when body changes' do
    subject { create(:post, body: 'One') }

    it 'changes its #sha' do
      expect { subject.update_attributes(body: 'Two') }
        .to change { subject.sha }
    end

    it 'stores the previous #sha in #previous_shas' do
      sha1 = subject.sha

      expect { subject.update_attributes(body: 'Two') }
        .to change { subject.previous_shas }
        .from([])
        .to([sha1])

      sha2 = subject.sha

      expect { subject.update_attributes(body: 'Three') }
        .to change { subject.previous_shas }
        .from([sha1])
        .to([sha1, sha2])
    end
  end

  context 'when body contains hashtags' do
    subject do
      create(:post, body: 'Hello #world, I feel #fine!')
    end

    it 'extracts those hashtags into the #tags attribute' do
      expect(subject.tags.map(&:name)).to eq(['world', 'fine'])
    end


    specify 'body_html contains auto-linked hashtags'
  end

  context 'when a line in the body starts with a hashtag' do
    subject do
      create(:post, body: "#hello\n\n#world, you're #awesome!")
    end

    it "doesn't convert the hashtag into a HTML heading" do
      expect(subject.tags.map(&:name)).to eq(['hello', 'world', 'awesome'])
    end
  end

  context 'getting posts tagged with a tag' do
    subject do
      create(:post, body: 'just a post with a #unicorn tag')
    end

    it 'returns the wanted post' do
      subject.reload
      expect(Post.tagged_with('unicorn')).to eq([subject])
    end
  end
end
