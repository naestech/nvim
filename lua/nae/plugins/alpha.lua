return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Read ASCII frames from file
		local function read_ascii_frames()
			local file = io.open("/Users/nadine/.config/nvim/strawhatsAscii.txt", "r")
			if not file then
				print("Could not open ASCII file")
				return {}
			end

			local frames = {}
			local current_frame = {}
			local in_frame = false
			
			for line in file:lines() do
				if line == "Frame:" then
					in_frame = true
				elseif line:match("^=+$") then -- Matches a line of equal signs
					if #current_frame > 0 then
						table.insert(frames, current_frame)
						current_frame = {}
					end
					in_frame = false
				elseif in_frame then
					table.insert(current_frame, line)
				end
			end
			
			-- Add the last frame if it exists
			if #current_frame > 0 then
				table.insert(frames, current_frame)
			end
			
			file:close()
			
			-- Debug message
			print("Loaded " .. #frames .. " frames")
			return frames
		end

		-- Create animation timer
		local function create_animation_timer(dashboard)
			local frames = read_ascii_frames()
			if #frames == 0 then return end
			
			local timer = vim.loop.new_timer()
			local frame_index = 1
			
			timer:start(0, 100, vim.schedule_wrap(function() -- 100ms between frames
				frame_index = (frame_index % #frames) + 1
				dashboard.section.header.val = frames[frame_index]
				alpha.redraw()
			end))
			
			-- Stop timer when leaving alpha
			vim.api.nvim_create_autocmd("BufLeave", {
				pattern = "alpha",
				callback = function()
					timer:stop()
				end,
			})
		end

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("e", "  > new file", "<cmd>ene<CR>"),
			dashboard.button("␣ ee", "  > toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
			dashboard.button("␣ ff", "󰱼  > find file", "<cmd>Telescope find_files<CR>"),
			dashboard.button("␣ fs", "  > find word", "<cmd>Telescope live_grep<CR>"),
			dashboard.button("␣ wr", "󰁯  > restore session", "<cmd>SessionRestore<CR>"),
			dashboard.button("q", "  > quit nvim", "<cmd>qa<CR>"),
		}

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])

		-- Replace the headers section with:
		local frames = read_ascii_frames()
		dashboard.section.header.val = frames[1] or {} -- Set first frame as default

		-- Start animation after alpha setup
		vim.api.nvim_create_autocmd("User", {
			pattern = "AlphaReady",
			callback = function()
				create_animation_timer(dashboard)
			end,
		})
	end,
}
