<cfcontent type="application/json" reset="yes">
<cfsilent><cfinclude template="/pages/boxscore/config.cfm"></cfsilent>

<cfset requestBody = deserializeJSON(toString(getHttpRequestData().content))>
<cfset imageBase64 = requestBody.image>

<cfset prompt = "Extract the playoff schedule from this image. It covers a single bracket only.

Output using exactly this format:

Sunday, April 12th (Semi-Finals)
10:30 AM - (1) Emerald BC vs (4) Taste Ticklers
11:35 AM - (2) CrossinOver Toddlers vs (3) Hustle Gang

Monday, April 13th (Championship)
6:30 PM - (1) Emerald BC vs (2) CrossinOver Toddlers

Rules:
- Include the seed number in parentheses immediately before each team name ONLY if a seed/number is shown next to that team in the image. Omit it otherwise.
- Use 'vs' lowercase between teams
- Preserve team names exactly as shown in the image, including unusual spellings
- If a game shows a placeholder instead of a real team name (e.g. 'Winner of Game 3', 'TBD'), keep that placeholder text exactly as shown instead of a team name
- Group each date under its own header line, in the format 'Weekday, Month Dayth' with the round name in parentheses if shown in the image
- Game line format: H:MM AM/PM, then ' - ', then the matchup
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

    <cfoutput>#serializeJSON({ 'schedule': rawText })#</cfoutput>
    <cfcatch>
        <cfoutput>#serializeJSON({ 'error': cfcatch.message, 'detail': cfcatch.detail, 'apiResponse': apiResponse.fileContent })#</cfoutput>
    </cfcatch>
</cftry>
