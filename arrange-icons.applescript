on run argv
	if (count of argv) < 1 or (count of argv) > 3 then
		error "Usage: osascript arrange-icons.applescript heart|woman|womanicon|trans|plus|smiley|cube|star [size-percent] [none|horizontal]" number 1
	end if
	
	set shapeName to item 1 of argv as text
	if shapeName is not "heart" and shapeName is not "woman" and shapeName is not "womanicon" and shapeName is not "trans" and shapeName is not "plus" and shapeName is not "smiley" and shapeName is not "cube" and shapeName is not "star" then
		error "Unknown shape. Choose heart, woman, womanicon, trans, plus, smiley, cube, or star." number 1
	end if
	
	set sizePercent to 80
	if (count of argv) >= 2 then
		try
			set sizeValue to item 2 of argv as real
		on error
			error "Size must be a whole-number percentage from 20 to 100." number 1
		end try
		set sizePercent to sizeValue as integer
		if sizeValue is not sizePercent then
			error "Size must be a whole-number percentage from 20 to 100." number 1
		end if
	end if
	if sizePercent < 20 or sizePercent > 100 then
		error "Size must be a whole-number percentage from 20 to 100." number 1
	end if
	
	set lineCompensation to "none"
	if (count of argv) is 3 then
		set lineCompensation to item 3 of argv as text
	end if
	if lineCompensation is not "none" and lineCompensation is not "horizontal" then
		error "Line compensation must be none or horizontal." number 1
	end if
	
	tell application "Finder"
		set desktopItems to (every file of desktop) & (every folder of desktop)
		if (count of desktopItems) is 0 then
			error "There are no desktop files or folders to arrange." number 1
		end if
		
		set desktopBounds to bounds of (window of desktop)
		set desktopWidth to (item 3 of desktopBounds) - (item 1 of desktopBounds)
		set desktopHeight to (item 4 of desktopBounds) - (item 2 of desktopBounds)
		set desktopMarginX to desktopWidth * 0.03
		set desktopMarginY to desktopHeight * 0.03
		set usableWidth to desktopWidth - (2 * desktopMarginX)
		set usableHeight to desktopHeight - (2 * desktopMarginY)
		if usableWidth < 1 or usableHeight < 1 then
			error "Could not determine usable desktop dimensions." number 1
		end if
		
		set itemCount to count of desktopItems
		set centerX to ((item 1 of desktopBounds) + (item 3 of desktopBounds)) / 2
		set centerY to ((item 2 of desktopBounds) + (item 4 of desktopBounds)) / 2
		set shapeOffsets to {}
		set minX to missing value
		set maxX to missing value
		set minY to missing value
		set maxY to missing value
		if shapeName is not "heart" and shapeName is not "smiley" then
			set shapePaths to my pathsForShape(shapeName)
		end if
		
		repeat with itemIndex from 1 to itemCount
			set progressAlongShape to (itemIndex - 1) / itemCount
			if shapeName is "heart" or shapeName is "smiley" then
				set pointOffset to my pointForShape(shapeName, progressAlongShape, 1)
				set end of pointOffset to false
			else
				set pointOffset to my pointOnPaths(shapePaths, progressAlongShape)
			end if
			set pointX to item 1 of pointOffset
			set pointY to item 2 of pointOffset
			set end of shapeOffsets to pointOffset
			if minX is missing value then
				set minX to pointX
				set maxX to pointX
				set minY to pointY
				set maxY to pointY
			else
				if pointX < minX then set minX to pointX
				if pointX > maxX then set maxX to pointX
				if pointY < minY then set minY to pointY
				if pointY > maxY then set maxY to pointY
			end if
		end repeat
		
		set shapeWidth to maxX - minX
		set shapeHeight to maxY - minY
		if shapeWidth is 0 or shapeHeight is 0 then
			error "There are not enough desktop items to draw this shape." number 1
		end if
		
		set scaleX to (usableWidth * sizePercent / 100) / shapeWidth
		set scaleY to (usableHeight * sizePercent / 100) / shapeHeight
		if scaleX < scaleY then
			set shapeScale to scaleX
		else
			set shapeScale to scaleY
		end if
		set shapeCenterX to (minX + maxX) / 2
		set shapeCenterY to (minY + maxY) / 2
		set targetPositions to {}
		
		repeat with itemIndex from 1 to itemCount
			set pointOffset to item itemIndex of shapeOffsets
			set targetX to centerX + (((item 1 of pointOffset) - shapeCenterX) * shapeScale)
			set targetY to centerY + (((item 2 of pointOffset) - shapeCenterY) * shapeScale)
			if lineCompensation is "horizontal" and item 3 of pointOffset then
				if (itemIndex mod 2) is 0 then
					set targetY to targetY + 20
				else
					set targetY to targetY - 20
				end if
			end if
			set targetPosition to {targetX, targetY}
			set end of targetPositions to targetPosition
			set desktop position of item itemIndex of desktopItems to targetPosition
		end repeat
		
		repeat with itemIndex from 1 to itemCount
			set actualPosition to desktop position of item itemIndex of desktopItems
			set targetPosition to item itemIndex of targetPositions
			set xDifference to (item 1 of actualPosition) - (item 1 of targetPosition)
			set yDifference to (item 2 of actualPosition) - (item 2 of targetPosition)
			if xDifference > 2 or xDifference < -2 or yDifference > 2 or yDifference < -2 then
				error "Finder did not keep the requested icon positions. Set Desktop View > Sort By > None, turn off Use Stacks, and try again." number 1
			end if
		end repeat
	end tell
	return "Arranged " & itemCount & " desktop items into a " & shapeName & " at " & sizePercent & "% size, horizontal line compensation: " & lineCompensation & "."
end run

on pointForShape(shapeName, progressAlongShape, shapeRadius)
	if shapeName is "heart" then
		set angle to 2 * 3.141592653589793 * progressAlongShape
		set angleDouble to 2 * angle
		set angleTriple to 3 * angle
		set angleQuadruple to 4 * angle
		set xOffset to shapeRadius * 16 * ((my sineValue(angle)) ^ 3) / 17
		set yOffset to -shapeRadius * (13 * (my cosineValue(angle)) - 5 * (my cosineValue(angleDouble)) - 2 * (my cosineValue(angleTriple)) - (my cosineValue(angleQuadruple))) / 17
		return {xOffset, yOffset}
	end if
	
	if progressAlongShape < 0.78 then
		set angle to 2 * 3.141592653589793 * progressAlongShape / 0.78
		return {shapeRadius * (my cosineValue(angle)), shapeRadius * (my sineValue(angle))}
	else if progressAlongShape < 0.88 then
		set eyeProgress to (progressAlongShape - 0.78) / 0.1
		if eyeProgress < 0.5 then
			return {shapeRadius * -0.35, shapeRadius * -0.32}
		else
			return {shapeRadius * 0.35, shapeRadius * -0.32}
		end if
	else
		set smileProgress to (progressAlongShape - 0.88) / 0.12
		set xOffset to shapeRadius * (smileProgress - 0.5) * 0.9
		set yOffset to shapeRadius * (0.12 + (0.3 * (1 - ((2 * smileProgress - 1) ^ 2))))
		return {xOffset, yOffset}
	end if
end pointForShape

on pathsForShape(shapeName)
	set paths to {}
	if shapeName is "plus" then
		set end of paths to {{0, -1}, {0, 1}}
		set end of paths to {{-1, 0}, {1, 0}}
	else if shapeName is "cube" then
		set end of paths to {{-0.5, -0.4}, {0.25, -0.4}}
		set end of paths to {{0.25, -0.4}, {0.25, 0.35}}
		set end of paths to {{0.25, 0.35}, {-0.5, 0.35}}
		set end of paths to {{-0.5, 0.35}, {-0.5, -0.4}}
		set end of paths to {{-0.15, -0.75}, {0.6, -0.75}}
		set end of paths to {{0.6, -0.75}, {0.6, 0}}
		set end of paths to {{0.6, 0}, {-0.15, 0}}
		set end of paths to {{-0.15, 0}, {-0.15, -0.75}}
		set end of paths to {{-0.5, -0.4}, {-0.15, -0.75}}
		set end of paths to {{0.25, -0.4}, {0.6, -0.75}}
		set end of paths to {{0.25, 0.35}, {0.6, 0}}
		set end of paths to {{-0.5, 0.35}, {-0.15, 0}}
	else if shapeName is "woman" then
		set end of paths to my circlePath(0.18, 0, -0.68)
		set end of paths to {{0, -0.43}, {-0.48, 0.3}, {0.48, 0.3}, {0, -0.43}}
		set end of paths to {{-0.19, 0.3}, {-0.25, 0.9}}
		set end of paths to {{0.19, 0.3}, {0.25, 0.9}}
	else if shapeName is "womanicon" then
		set end of paths to my circlePath(0.42, 0, -0.3)
		set end of paths to {{0, 0.12}, {0, 0.72}}
		set end of paths to {{-0.3, 0.55}, {0.3, 0.55}}
	else if shapeName is "trans" then
		set end of paths to my circlePath(0.42, -0.06, 0.02)
		set end of paths to {{0.237, -0.277}, {0.6, -0.64}, {0.29, -0.64}, {0.6, -0.64}, {0.6, -0.33}}
		set end of paths to {{-0.357, -0.277}, {-0.72, -0.64}, {-0.41, -0.64}, {-0.72, -0.64}, {-0.72, -0.33}}
		set end of paths to {{-0.54, -0.46}, {-0.4, -0.6}}
		set end of paths to {{-0.06, 0.44}, {-0.06, 0.82}}
		set end of paths to {{-0.22, 0.68}, {0.1, 0.68}}
	else if shapeName is "star" then
		set end of paths to my starPath()
	end if
	return paths
end pathsForShape

on starPath()
	set points to {}
	set outerRadius to 1
	set innerRadius to 0.42
	repeat with vertexIndex from 0 to 10
		set vertexRadius to outerRadius
		if (vertexIndex mod 2) is 1 then set vertexRadius to innerRadius
		set angle to (2 * 3.141592653589793 * vertexIndex / 10) - (3.141592653589793 / 2)
		set pointX to vertexRadius * (my cosineValue(angle))
		set pointY to vertexRadius * (my sineValue(angle))
		set end of points to {pointX, pointY}
	end repeat
	return points
end starPath

on circlePath(radius, centerX, centerY)
	set points to {}
	set sampleCount to 40
	repeat with sampleIndex from 0 to sampleCount
		set angle to 2 * 3.141592653589793 * sampleIndex / sampleCount
		set pointX to centerX + (radius * (my cosineValue(angle)))
		set pointY to centerY + (radius * (my sineValue(angle)))
		set end of points to {pointX, pointY}
	end repeat
	return points
end circlePath

on pointOnPaths(paths, progressAlongShape)
	set pathLengths to {}
	set totalLength to 0
	repeat with pathPoints in paths
		set currentLength to my polylineLength(pathPoints)
		set end of pathLengths to currentLength
		set totalLength to totalLength + currentLength
	end repeat
	if totalLength is 0 then error "Shape path has no length." number 1
	
	set targetDistance to progressAlongShape * totalLength
	set traversedDistance to 0
	repeat with pathIndex from 1 to count of paths
		set currentLength to item pathIndex of pathLengths
		if targetDistance <= traversedDistance + currentLength or pathIndex is (count of paths) then
			set pathProgress to (targetDistance - traversedDistance) / currentLength
			if pathProgress < 0 then set pathProgress to 0
			if pathProgress > 1 then set pathProgress to 1
			return my pointOnPolyline(item pathIndex of paths, pathProgress)
		end if
		set traversedDistance to traversedDistance + currentLength
	end repeat
	error "Could not find a point along the shape path." number 1
end pointOnPaths

on pointOnPolyline(points, progressAlongPath)
	set totalLength to my polylineLength(points)
	if totalLength is 0 then error "Shape path has no length." number 1
	set targetDistance to progressAlongPath * totalLength
	set traversedDistance to 0
	repeat with segmentIndex from 1 to (count of points) - 1
		set startPoint to item segmentIndex of points
		set endPoint to item (segmentIndex + 1) of points
		set segmentLength to my distanceBetween(startPoint, endPoint)
		if targetDistance <= traversedDistance + segmentLength or segmentIndex is ((count of points) - 1) then
			set segmentProgress to (targetDistance - traversedDistance) / segmentLength
			if segmentProgress < 0 then set segmentProgress to 0
			if segmentProgress > 1 then set segmentProgress to 1
			set interpolatedPoint to my interpolatePoint(item 1 of startPoint, item 2 of startPoint, item 1 of endPoint, item 2 of endPoint, segmentProgress)
			set verticalDifference to (item 2 of endPoint) - (item 2 of startPoint)
			set horizontalFlag to false
			if verticalDifference < 0.0001 and verticalDifference > -0.0001 then set horizontalFlag to true
			return {item 1 of interpolatedPoint, item 2 of interpolatedPoint, horizontalFlag}
		end if
		set traversedDistance to traversedDistance + segmentLength
	end repeat
	error "Could not find a point along the shape path." number 1
end pointOnPolyline

on polylineLength(points)
	set totalLength to 0
	repeat with segmentIndex from 1 to (count of points) - 1
		set totalLength to totalLength + my distanceBetween(item segmentIndex of points, item (segmentIndex + 1) of points)
	end repeat
	return totalLength
end polylineLength

on distanceBetween(pointA, pointB)
	set deltaX to (item 1 of pointB) - (item 1 of pointA)
	set deltaY to (item 2 of pointB) - (item 2 of pointA)
	return ((deltaX * deltaX) + (deltaY * deltaY)) ^ 0.5
end distanceBetween

on interpolatePoint(startX, startY, endX, endY, progress)
	return {startX + ((endX - startX) * progress), startY + ((endY - startY) * progress)}
end interpolatePoint

on sineValue(angle)
	set reducedAngle to angle
	set piValue to 3.141592653589793
	repeat while reducedAngle > piValue
		set reducedAngle to reducedAngle - (2 * piValue)
	end repeat
	repeat while reducedAngle < -piValue
		set reducedAngle to reducedAngle + (2 * piValue)
	end repeat
	
	set resultValue to reducedAngle
	set termValue to reducedAngle
	repeat with termIndex from 1 to 10
		set termValue to termValue * (0 - reducedAngle * reducedAngle) / ((2 * termIndex) * ((2 * termIndex) + 1))
		set resultValue to resultValue + termValue
	end repeat
	return resultValue
end sineValue

on cosineValue(angle)
	set reducedAngle to angle
	set piValue to 3.141592653589793
	repeat while reducedAngle > piValue
		set reducedAngle to reducedAngle - (2 * piValue)
	end repeat
	repeat while reducedAngle < -piValue
		set reducedAngle to reducedAngle + (2 * piValue)
	end repeat
	
	set resultValue to 1
	set termValue to 1
	repeat with termIndex from 1 to 10
		set termValue to termValue * (0 - reducedAngle * reducedAngle) / (((2 * termIndex) - 1) * (2 * termIndex))
		set resultValue to resultValue + termValue
	end repeat
	return resultValue
end cosineValue
