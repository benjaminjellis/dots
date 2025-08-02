local logo = [[    ____  _______    _______   ____    _____  ___  ___      ___  __     ___      ___ 
   /   ")|   _  "\  /"     "| (  " \  (\"   \|"  \|"  \    /"  ||" \   |"  \    /"  |
  /. __/ (. |_)  :)(: ______)  \__. \ |.\\   \    |\   \  //  / ||  |   \   \  //   |
 // /    |:     \/  \/    |       ) :)|: \.   \\  | \\  \/. ./  |:  |   /\\  \/.    |
(: (___  (|  _  \\  // ___)_   __/ // |.  \    \. |  \.    //   |.  |  |: \.        |
 \     ) |: |_)  :)(:      "| /"   /  |    \    \ |   \\   /    /\  |\ |.  \    /:  |
  \"__/  (_______/  \_______)(____/    \___|\____\)    \__/    (__\_|_)|___|\__/|___|
                                                                                     ]]
local twistedLogo = [[  __     _____     _____  __   __   __    _     _   __    __    __   
 /\_\  /\  __/\  /\_____\/_/\ /_/\ /\_\  /_/\ /\_\ /\_\  /_/\  /\_\  
( ( (  ) )(_ ) )( (_____/) ) )) ) \ ( (  ) ) ) ( ( \/_/  ) ) \/ ( (  
 \ \_\/ / __/ /  \ \__\ /_/ //_/   \\_\/_/ / \ \_\ /\_\/_/ \  / \_\ 
 / / /\ \  _\ \  / /__/_\ \ \\ \ \   / /\ \ \_/ / // / /\ \ \\// / / 
( (_(  ) )(__) )( (_____\)_) ))_) \ (_(  \ \   / /( (_(  )_) )( (_(  
 \/_/  \/____\/  \/_____/\_\/ \_\/ \/_/   \_\_/_/  \/_/  \_\/  \/_/  ]]
local ivy = [[
          /^-^\        
         / o o \       
        /   Y   \      
        V \ v / V      
          / - \        
         /    |        
   (    /     |        
    ---/___)| |         ]]
local theRewardForGoodWork = "The Reward For Good Work Is More Work"
return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        sections = {
          { section = "header" },
          { section = "keys" },
          { text = "", align = "center" },
          { section = "startup" },
        },

        preset = {
          header = logo .. "\n\n" .. ivy .. "\n\n\n" .. theRewardForGoodWork,
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
  },
}
