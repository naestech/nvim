return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Get all ASCII animation files in sorted order
		local function get_ascii_files()
			-- print("Searching for ASCII files...")
			local handle = io.popen('ls "/Users/nae/.config/nvim/ascii/"*Ascii.txt | sort')
			if not handle then
				--	print("Failed to execute ls command")
				return {}
			end

			local files = {}
			for file in handle:lines() do
				--	print("Found file: " .. file)
				table.insert(files, file)
			end
			handle:close()

			if #files == 0 then
			--	print("No ASCII files found in directory")
			else
				--	print("Found " .. #files .. " ASCII files")
			end
			return files
		end

		-- Get the next ASCII file to display
		local function get_next_ascii_file()
			local files = get_ascii_files()
			if #files == 0 then
				return nil
			end

			-- Read/write state file to track which animation to show
			local state_file = "/Users/nae/.config/nvim/ascii/last_shown.txt"
			local last_shown = ""

			-- Try to read last shown file
			local f = io.open(state_file, "r")
			if f then
				last_shown = (f:read("*line") or ""):gsub("%%$", "") -- Remove trailing % if it exists
				f:close()
			end
			-- print("Last shown file was: '" .. last_shown .. "'") -- Debug print with quotes

			-- Find current index and calculate next
			local current_index = 1
			for i, file in ipairs(files) do
				--	print("Comparing '" .. file .. "' with '" .. last_shown .. "'") -- Debug comparison
				if file == last_shown then
					current_index = i
					break
				end
			end

			-- Calculate next index (wrap around to 1 if at end)
			local next_index = current_index + 1
			if next_index > #files then
				next_index = 1
			end

			local next_file = files[next_index]
			--	print("Current index: " .. current_index .. ", Next index: " .. next_index)
			--	print("Next file will be: '" .. next_file .. "'")

			-- Save next file
			f = io.open(state_file, "w")
			if f then
				f:write(next_file)
				f:close()
			end

			return next_file
		end

		-- Read ASCII frames from file
		local function read_ascii_frames(chosen_file)
			local file = io.open(chosen_file, "r")
			if not file then
				--		print("Could not open ASCII file: " .. chosen_file)
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
		local function create_animation_timer(dashboard, chosen_file)
			if not chosen_file then
				return
			end

			local frames = read_ascii_frames(chosen_file)
			if #frames == 0 then
				return
			end

			-- Set initial frame
			dashboard.section.header.val = frames[1]
			alpha.redraw()

			local timer = vim.loop.new_timer()
			local frame_index = 1

			timer:start(
				0,
				50,
				vim.schedule_wrap(function()
					frame_index = (frame_index % #frames) + 1
					dashboard.section.header.val = frames[frame_index]
					alpha.redraw()
				end)
			)

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

		-- Set up initial header and animation
		local chosen_file = get_next_ascii_file()
		if chosen_file then
			local initial_frames = read_ascii_frames(chosen_file)
			if #initial_frames > 0 then
				dashboard.section.header.val = initial_frames[1]
			end
		end

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])

		-- Start animation after alpha setup
		vim.api.nvim_create_autocmd("User", {
			pattern = "AlphaReady",
			callback = function()
				create_animation_timer(dashboard, chosen_file)
			end,
		})
	end,
}
