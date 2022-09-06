module OpendotaHelper
  def format_rank(num, leaderboard_rank=nil)
    # Uncalibrated players pass nil, so default should be 0
    num ||= 0

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
