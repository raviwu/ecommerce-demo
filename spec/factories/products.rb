FactoryGirl.define do
  factory :product do
    name "AT&T 4G Phone Card"
    description <<-EOS.strip_heredoc
    ☆ AT&T預付卡(美國手機門號)，享用美國當地話費，以及手機在美國上網！
    ☆ 美國AT&T是全球最大的電信公司，在美國有最大的訊號範圍
    ☆ 已開卡，到達美國後，將美國SIM卡插入台灣三頻手機，即可立即使用!
    ☆ 限掛寄出免運費，上班日13:00前付款當天寄出，最快隔日即可收到  急用請參考
    ☆ 免費 iPhone 剪卡服務，限可通話的手機使用；平板電腦/iPad/行動分享器無法使用
    EOS
    properties {
      {
        color: %w(red black yellow),
        bandwidth: %w(1G 3G 5G)
      }
    }
    available_on { Time.current }

    association :classification
  end
end
