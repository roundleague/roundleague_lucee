<cfcontent type="application/json" reset="yes">
<cfsilent><cfinclude template="/pages/boxscore/config.cfm"></cfsilent>

<cfset requestBody = deserializeJSON(toString(getHttpRequestData().content))>
<cfset imageBase64 = requestBody.image>
<cfset divisions = requestBody.divisions>
<cfset divisionList = arrayToList(divisions, ", ")>

<cfset prompt = "Extract the complete basketball schedule from this image.

The database has these divisions: #divisionList#

Group ALL games that belong to the same division together under one section, even if they appear in separate time slots or days in the image. Match each section to the closest division name from the list above.

Output using exactly this format:

[DIVISION: Open Division]
Week 1 - Sunday, May 3rd
9:15 AM	Friends of Westside vs Taste Ticklers
10:20 AM	Skin N Bones vs Whippersnappers
Week 1 - Monday, May 4th
6:15 PM	Fire Horses vs LLFA

[DIVISION: Premiere Division]
Week 1 - Sunday, May 3rd
1:35 PM	Brokke Boys vs NW Cardboard

Rules:
- Use the EXACT division name from the database list (e.g. 'Open Division', not 'Open Division - Sunday Morning')
- If a division appears in multiple sessions/days, combine them all under one [DIVISION] header
- Week header format: 'Week N - Weekday, Month Dayth'
- Game line format: H:MM AM/PM, then a TAB character, then 'Home Team vs Away Team'
- Use 'vs' lowercase between teams
- Preserve team names exactly as shown in the image, including unusual spellings
- No extra text outside of this format">

<cftry>
    <cfhttp url="https://api.openai.com/v1/chat/completions" method="post" result="apiResponse">
        <cfhttpparam type="header" name="Authorization" value="Bearer #apiKey#">
        <cfhttpparam type="header" name="Content-Type" value="application/json">
        <cfhttpparam type="body" value="#serializeJSON({
            'model': 'gpt-4o-mini',
            'max_tokens': 2048,
            'messages': [{
                'role': 'user',
                'content': [
                    {
                        'type': 'image_url',
                        'image_url': { 'url': 'data:image/jpeg;base64,#imageBase64#' }
                    },
                    {
                        'type': 'text',
                        'text': prompt
                    }
                ]
            }]
        })#">
    </cfhttp>

    <cfset parsed = deserializeJSON(apiResponse.fileContent)>
    <cfset rawText = parsed.choices[1].message.content>

    <!--- Parse [DIVISION: ...] markers into a struct --->
    <cfset scheduleByDivision = {}>
    <cfset lines = listToArray(rawText, chr(10))>
    <cfset currentDivision = "">
    <cfset currentLines = []>

    <cfloop array="#lines#" index="line">
        <cfset line = replace(line, chr(13), "", "all")>
        <cfif reFind("^\[DIVISION: .+\]$", trim(line))>
            <cfif len(currentDivision) AND arrayLen(currentLines)>
                <cfset scheduleByDivision[currentDivision] = trim(arrayToList(currentLines, chr(10)))>
            </cfif>
            <cfset currentDivision = reReplace(trim(line), "^\[DIVISION: (.+)\]$", "\1")>
            <cfset currentLines = []>
        <cfelseif len(currentDivision) AND len(trim(line))>
            <cfset arrayAppend(currentLines, rtrim(line))>
        </cfif>
    </cfloop>

    <!--- Capture last division --->
    <cfif len(currentDivision) AND arrayLen(currentLines)>
        <cfset scheduleByDivision[currentDivision] = trim(arrayToList(currentLines, chr(10)))>
    </cfif>

    <cfoutput>#serializeJSON({ 'schedule': scheduleByDivision })#</cfoutput>
    <cfcatch>
        <cfoutput>#serializeJSON({ 'error': cfcatch.message, 'detail': cfcatch.detail, 'apiResponse': apiResponse.fileContent })#</cfoutput>
    </cfcatch>
</cftry>
