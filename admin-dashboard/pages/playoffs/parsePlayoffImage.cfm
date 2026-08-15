<cfcontent type="application/json" reset="yes">
<cfsilent><cfinclude template="/pages/boxscore/config.cfm"></cfsilent>

<cfset requestBody = deserializeJSON(toString(getHttpRequestData().content))>
<cfset imageBase64 = requestBody.image>

<cfset prompt = "Extract the complete basketball playoff schedule from this image, exactly as printed.

Output using exactly this format:

Sunday, April 12th (Semi-Finals)
10:30AM - ##1 Emerald BC vs ##4 Taste Ticklers
11:35AM - ##2 CrossinOver Toddlers vs ##3 Hustle Gang

Monday, April 13th (Championship)
6:30PM - WINNER GAME 1 vs WINNER GAME 2

Rules:
- Each date line is the weekday and date, optionally followed by a round name in parentheses, e.g. 'Sunday, April 12th (Semi-Finals)'
- Each game line starts with the start time (H:MMAM/PM), then ' - ', then the matchup with 'vs' between the two sides
- If a team slot shows a seed number (whether printed in parentheses or with a ## symbol), prefix the team name with '##' followed by the seed number and a space, e.g. '##1 Emerald BC'
- If a team slot is not yet determined (shows text like 'Winner Game 1', 'Loser Game 2', or 'Winner (2/7)'), transcribe that placeholder text exactly as shown, preserving whether it says WINNER or LOSER and the game number or seed pair
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
    <cfset rawText = trim(parsed.choices[1].message.content)>

    <cfoutput>#serializeJSON({ 'text': rawText })#</cfoutput>
    <cfcatch>
        <cfoutput>#serializeJSON({ 'error': cfcatch.message, 'detail': cfcatch.detail, 'apiResponse': apiResponse.fileContent })#</cfoutput>
    </cfcatch>
</cftry>
