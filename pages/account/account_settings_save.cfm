<cfinclude template="/header.cfm">

<cfoutput>
<cfquery name="updatePlayer" datasource="roundleague">
    UPDATE Players 
    SET 
        Email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">,
        FirstName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.firstName#">,
        LastName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lastName#">,
        BirthDate = <cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(form.birthDate, "mm/dd/yyyy")#">,
        Phone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Phone#">,
        HighestLevel = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.HighestLevel#">,
        Position = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Position#">,
        Height = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Height#">,
        Weight = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Weight#">,
        Hometown = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Hometown#">,
        School = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.School#">,
        Instagram = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Instagram#">,
        Gender = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Gender#">,
        ZipCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.zipCode#">,
        ModifiedDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
    WHERE PlayerID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.playerID#">
</cfquery>

<!--- Update jersey number in roster table --->
<cfquery name="updateJersey" datasource="roundleague">
    UPDATE Roster
    SET Jersey = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.currentJersey#">
    WHERE PlayerID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.playerID#">
    AND SeasonID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.currentSeasonID#">
</cfquery>

<!--- Update email and password in users table --->
<cfquery name="updateUser" datasource="roundleague">
    UPDATE users
    SET 
        userName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">
        <cfif len(trim(form.password))>
        , password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(form.password, 'SHA')#">
        </cfif>
    WHERE playerID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.playerID#">
</cfquery>

<div class="main" style="background-color: white; margin-top: 50px;">
    <div class="section text-center">
        <div class="container">
            <div class="alert alert-success">
                <p>Your profile has been successfully updated!</p>
                <a href="account_settings.cfm?playerID=#form.playerID#" class="btn btn-info">Back to Settings</a>
            </div>
        </div>
    </div>
</div>
</cfoutput>
<cfinclude template="/footer.cfm">
