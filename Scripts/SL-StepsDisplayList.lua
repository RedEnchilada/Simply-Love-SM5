function GetStepsToDisplay(AllAvailableSteps, player)

	--gather any edit charts into a table
	local edits = {}
	local StepsToShow = {}

	for k,chart in ipairs(AllAvailableSteps) do

		local difficulty = chart:GetDifficulty()
		if GAMESTATE:IsCourseMode() then
			local index = GetYOffsetByDifficulty(difficulty)
			StepsToShow[index] = chart
		else
			if chart:IsAnEdit() then
				edits[#edits+1] = chart
			else
				local index = GetYOffsetByDifficulty(difficulty)
				StepsToShow[index] = chart
			end
		end
	end

	-- if there are no edits we can safely bail now
	if #edits == 0 then return StepsToShow end



	--THERE ARE EDITS, OH NO!
	--HORRIBLE HANDLING/LOGIC BELOW

	for k,edit in ipairs(edits) do
		StepsToShow[5+k] = edit
	end

	local currentSteps = GAMESTATE:GetCurrentSteps(player)
	local finalReturn = {}

	-- if only one player is joined

		-- if the current chart is an edit
		if currentSteps:IsAnEdit() then

			local currentIndex

			-- We've used GAMESTATE:GetCurrentSteps(pn) to get the current chart
			-- use a for loop to match that "current chart" against each chart
			-- in our charts table; we want the index of the current chart
			for k,chart in pairs(StepsToShow) do
				if chart:GetChartName()==currentSteps:GetChartName() then
					currentIndex = tonumber(k)
				end
			end

			local frIndex = 5

			-- "i" will decrement here
			-- if there is one edit chart, it will assign charts to finalReturn like
			-- [5]Edit, [4]Challenge, [3]Hard, [2]Medium, [1]Easy
			--
			-- if there are two edit charts, it will assign charts to finalReturn like
			-- [5]Edit, [4]Edit, [3]Challenge, [2]Hard, [1]Medium
			-- and so on
			for i=currentIndex, currentIndex-4, -1 do
				finalReturn[frIndex] = StepsToShow[i]
				frIndex = frIndex - 1
			end

		-- else we are somewhere in the normal five difficulties
		-- and are, for all intents and purposes, uninterested in any edits for now
		-- so remove all edits from the table we're returning
		else

			for k,chart in pairs(StepsToShow) do
				if chart:IsAnEdit() then
					StepsToShow[k] = nil
				end
			end

			return StepsToShow
		end

	return finalReturn
end