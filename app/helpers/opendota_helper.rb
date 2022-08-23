module OpendotaHelper
  # Uncalibrated players pass nil, so default should be 0
  def format_rank(num=0, leaderboard_rank=nil)
    ranks = ["Uncalibrated", "Herald",  "Guardian", "Crusader", "Archon",
             "Legend",       "Ancient", "Divine",   "Immortal"]
    medal = ranks[num / 10]
    if num % 10 > 0
      "#{medal} #{num % 10}"    
    elsif num == 80 && leaderboard_rank
      "#{medal} #{leaderboard_rank}"
    else
      medal
    end
  end
end
