require 'rails_helper'

# Ignore whitespace
def expect_equal_ignoring_ws(first, second)
  expect(first.lines.map(&:strip).join('')).to eq(second.lines.map(&:strip).join(''))
end

describe Govuk::MarkdownRenderer do
  let(:html) { Govuk::MarkdownRenderer.render(markdown) }

  describe 'ul' do
    let(:markdown) do
      <<~MD
        - item
        - item
        - item
      MD
    end

    it 'renders correct HTML' do
      expected_html = <<~HTML
        <ul class="govuk-list govuk-list--bullet">
          <li>item</li>
          <li>item</li>
          <li>item</li>
        </ul>
      HTML

      expect_equal_ignoring_ws(html, expected_html)
    end
  end

  describe 'ol' do
    let(:markdown) do
      <<~MD
        1. item
        1. item
        1. item
      MD
    end

    it 'renders correct HTML' do
      expected_html = <<~HTML
        <ol class="govuk-list govuk-list--number">
          <li>item</li>
          <li>item</li>
          <li>item</li>
        </ol>
      HTML

      expect_equal_ignoring_ws(html, expected_html)
    end
  end

  describe 'link' do
    let(:markdown) do
      <<~MD
        [link](https://href)
      MD
    end

    it 'renders correct HTML' do
      expected_html = <<~HTML
        <p class="govuk-body">
          <a href="https://href" title="" class="govuk-link">link</a>
        </p>
      HTML

      expect_equal_ignoring_ws(html, expected_html)
    end
  end

  describe 'script safe' do
    let(:markdown) do
      <<~MD
        <script>alert(1);</script>
      MD
    end

    it 'renders correct HTML' do
      expect(html).to eq('')
    end
  end

  describe 'h1' do
    let(:markdown) do
      <<~MD
        # heading level 1
      MD
    end

    it 'renders correct HTML' do
      expected_html = <<~HTML
        <h1 class="govuk-heading-xl">heading level 1</h1>
      HTML

      expect_equal_ignoring_ws(html, expected_html)
    end
  end

  describe 'h2' do
    let(:markdown) do
      <<~MD
        ## heading level 2
      MD
    end

    it 'renders correct HTML' do
      expected_html = <<~HTML
        <h2 class="govuk-heading-l">heading level 2</h2>
      HTML

      expect_equal_ignoring_ws(html, expected_html)
    end
  end

  describe 'h3' do
    let(:markdown) do
      <<~MD
        ### heading level 3
      MD
    end

    it 'renders correct HTML' do
      expected_html = <<~HTML
        <h3 class="govuk-heading-m">heading level 3</h3>
      HTML

      expect_equal_ignoring_ws(html, expected_html)
    end
  end

  describe 'h4' do
    let(:markdown) do
      <<~MD
        #### heading level 4
      MD
    end

    it 'renders correct HTML' do
      expected_html = <<~HTML
        <h4 class="govuk-heading-s">heading level 4</h4>
      HTML

      expect_equal_ignoring_ws(html, expected_html)
    end
  end

  describe 'h5' do
    let(:markdown) do
      <<~MD
        ##### heading level 5
      MD
    end

    it 'renders correct HTML' do
      expected_html = <<~HTML
        <h5 class="govuk-heading-s">heading level 5</h5>
      HTML

      expect_equal_ignoring_ws(html, expected_html)
    end
  end

  context 'h6' do
    let(:markdown) do
      <<~MD
        ###### heading level 6
      MD
    end

    it 'renders correct HTML' do
      expected_html = <<~HTML
        <h6 class="govuk-heading-s">heading level 6</h6>
      HTML

      expect_equal_ignoring_ws(html, expected_html)
    end
  end
end
