<?xml version="1.0" encoding="ISO-8859-1"?>



<!--	feuille de style avec affichage du resultat du step, et suivi des FT
	Les données relatives au test sont affichées dans un premier tableau, le cartouche
        Les résultats du test, pour chaque step, sont affichés dans un tableau en encapsulant deux autres
        Le premier tableau n'a pas le cadre apparent. Il permet de placer l'entête avec le nom des colonnes
        Le second tableau à les colonnes et lignes apparentes, il permet de séparer les différents steps
	Enfin le troisième tableau, encapsulé dans le second, permet l'affichage des messages dans deux colonnes différentes  -->



<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:ms="urn:schemas-microsoft-com:xslt" 
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user="http://alladin/namespace"  	 
	version="1.0">
<xsl:output method="html" 
            indent="yes"
						media-type="text/html; charset=ISO-8859-1"
            encoding="ISO-8859-1"/>


<!-- variables globales -->
<xsl:variable name="ToleranceTemporelle" select='0.101'/>

<!-- nombres d'interfaces -->
<xsl:variable name="NbInterface" select="testInterfacesCount"/>

<xsl:variable name="NbInterfaceHost">
  <xsl:variable name="InterfaceHostNode" select="testInterface[contains(.,'Host')]"/>
  <xsl:value-of select="count($InterfaceHostNode)"/>
</xsl:variable>

<xsl:variable name="NbInterfaceLink">
  <xsl:variable name="InterfaceLinkNode" select="testInterface[contains(.,'Link') or contains(.,'Slp')]"/>
  <xsl:value-of select="count($InterfaceLinkNode)"/>
</xsl:variable>

<xsl:variable name="StylesheetFilePath">
  <xsl:value-of select="/test/stylesheetFilePath"/>
</xsl:variable>

<!-- nombre de caractères maxi admissibles pour une chaîne dans les colonnes messages
     Au delà de cette taille, il faut couper la chaîne pour ne pas élargir les colonnes
     J'ai déterminé cette valeur empiriquement, en essayant différentes valeurs.
     Cette valeur dépend de la taille de la police utilisée, elle est déterminée
     pour utiliser des caractères majuscules -->
     
<xsl:variable name="NbCarMaxColExigence" select="30"/>
<xsl:variable name="NbCarMaxColStep" select="1000"/>
<xsl:variable name="NbCarMaxColResult" select="12"/>

<xsl:template match="test"> 

<HTML>
<HEAD>
<TITLE><xsl:value-of select="testTitle" /></TITLE>
</HEAD>

<!-- titre de la fiche de test -->
<H1 align='center'><xsl:value-of select="testTitle" /></H1>

<body>

  <!-- saut de ligne avant affichage cartouche -->
  <br/><br/><br/>

  <!-- cartouche de la fiche de test -->
  <table border="1.0" rules="all" cellpadding="0" cellspacing="0">
    <tr>
      <td width="1000"><b><u>Titre du test</u>&#160;:&#160;</b><xsl:value-of select="substring(testTitle,0)" /></td>
    </tr>

     <!-- affichage des commentaires -->
	<xsl:for-each select="testComment">
		<tr>
		<td>
		<b><u><xsl:value-of select="./commentTitle"/></u></b><br/>

		<xsl:for-each select="commentBody/commentLine">
			<xsl:value-of select="."/><br/>
		</xsl:for-each>
		</td>
		</tr>
	</xsl:for-each>

    <tr>
      <td><b><u>Nombre d'interfaces</u>&#160;:&#160;</b><xsl:value-of select="$NbInterface" /></td>
    </tr>
    
  </table>						<!-- fin du cartouche -->

  <!-- saut de ligne avant affichage des resultats -->
  <br/><br/><br/><br/><br/>

  <!-- tableau principal -->
  <table border="0" cellspacing="0" cellpadding="0">

    <colgroup>
      <col width="150"/>
      <col width="250"/>
      <col width="0"/>
      <col width="250"/>
      <col width="260" align="center"/>
      <col width="230" align="center"/>
      <col width="80" align="center"/>
    </colgroup>

    <!-- premiere ligne -->

    <tr align='center'>
	<td align="left">Step</td>
	<td align="left">HOST</td>
	<td align="right">DLIP</td>
	<td align="right">LDT</td>
	<td align="center">Commentaires</td>
	<td align="center">Exigences</td>
      <td align="center">Result</td>
    </tr>

    <tr>

      <!-- fusion des cellules pour l'insertion du second tableau -->
      <td colspan="7">

      <!--traitement des steps--> 
      <xsl:apply-templates select="step"/>

      </td>

    </tr>

  </table>

</body>

</HTML>

</xsl:template>


<xsl:template match="step">

  <!-- insertion du second tableau -->
  <table border="1" cellpadding="0" cellspacing="0">

    <tr>

      <td width="150" valign="top"><xsl:call-template name="T_AfficheStep"/></td>


      <!-- fusion des cellules pour le troisieme tableau -->
      <td colspan="2">

      <!-- troisieme tableau au niveau des messages -->
      <table border="1" rules="cols" frame="void" width="520" cellpadding="0" cellspacing="0">

      <!-- traitement de tous les messages -->
      <xsl:apply-templates select="message"/>

     </table>						<!-- fin tableau 3 -->
     </td>						

     <!-- affichage des commentaires -->
     <td width="260" valign="top">
      <font size="2">
        <xsl:for-each select="stepComment">
        
          <xsl:variable name="UnCommentTitle">
            <xsl:value-of select="./commentTitle"/>
          </xsl:variable>
        
          <!-- affichage du titre du commentaire uniquement s'il y en a un -->
          <xsl:if test="$UnCommentTitle != ''"> 
		        <u><xsl:value-of select="$UnCommentTitle"/></u><br/>
          </xsl:if>
          <xsl:for-each select="commentBody/commentLine">
      	    <xsl:value-of select="."/><br/>
	        </xsl:for-each>
	        <br/>
	      </xsl:for-each>
	      &#160;
     </font>
     </td>

     <!--Affichage des exigences -->
     <td width="230" valign="top">
     <font size="1">
       <xsl:for-each select="stepRequirement">
         <xsl:choose>
           <xsl:when test="$NbCarMaxColExigence > string-length(.)">
             <xsl:value-of select="."/>
           </xsl:when>
           <xsl:otherwise>
             <xsl:call-template name="T_CoupeChaine">
               <xsl:with-param name="NbCarMax" select="$NbCarMaxColExigence"/>
               <xsl:with-param name="LaChaine" select="."/>
             </xsl:call-template>
           </xsl:otherwise>
         </xsl:choose>
         <br/>
      </xsl:for-each>
      &#160;
     </font>
     </td>

     <!-- afichage des resultats et FT -->
     <td width="80" valign="top">
     <font size="2">
       <xsl:call-template name="T_AfficheResultat"/>
       <xsl:call-template name="T_AfficheFT"/> 
     </font>
     </td>
	  
     </tr>

   </table>

</xsl:template>


<xsl:template match="message">

 <xsl:variable name="MessageSuivant" select="following-sibling::message[1]"/>

 <!-- variable datenumerique et datenumeriquesuivante pour pouvoir effectuer
      les tests d'affichage des messages, avec une tolérence temporelle de 100 ms -->

 <xsl:variable name="datenumerique">
    <!-- conversion de la date au format numerique -->
    <xsl:call-template name="T_ConversionDate" /> 
 </xsl:variable>

 <xsl:variable name="datenumeriquesuivante">
    <!-- conversion de la date au format numerique -->
    <xsl:call-template name="T_ConversionDate">
      <xsl:with-param name="UnMessage" select="$MessageSuivant"/>
    </xsl:call-template> 
 </xsl:variable>


 <!-- variable IsAL11UnCheckedMessage pour ne pas afficher les messages L11
      M.1, M.81, M.12.31 et M.9D s'ils n'ont aucun champ checké -->

 <xsl:variable name="IsAL11UnCheckedMessage">
 <!-- TODO : ajouter un test sur l'interface pour s'assurer qu'il s'agit d'une Interface L11 -->
   <xsl:choose>
     <xsl:when test="contains(messageName,'M.1') or contains(messageName,'M.81') or contains(messageName,'M.12.31') or contains(messageName,'M.9D')">
       <xsl:if test="field = ''">
       <!-- noeud field vide => aucun champ checké, le message ne doit pas être affiché -->
         <xsl:value-of select="'true'"/>
       </xsl:if>
       <xsl:if test="field != ''">
         <xsl:value-of select="'false'"/>
       </xsl:if>
     </xsl:when>
     <xsl:otherwise>
       <xsl:value-of select="'false'"/>
     </xsl:otherwise>
   </xsl:choose> 
 </xsl:variable>

<xsl:if test="$IsAL11UnCheckedMessage = 'false'">

 <xsl:choose> 

 <!-- si le message n'a pas ete ecrit au tour precedent -->
 <xsl:when test="user:str_GetNonEcrit() = 0" >
 
  <xsl:choose>

 
    <!-- traitement des messages d'interface host -->
    <xsl:when test="contains(@interface,'Host_Interface')">

      <!-- si le message suivant a le meme type, alors 1 seul message sur la ligne -->   
      <xsl:if test="$MessageSuivant/@interface = @interface">
        <tr>
          <td width="50%">
            <!-- affichage du message courant -->
            <xsl:call-template name="T_AfficheMessage"/>
          </td>
          <td width="50%"><!-- cellule vide -->&#160;</td>
        </tr>
      </xsl:if>

      <!-- si le message suivant n'a pas le meme type -->
      <xsl:if test="$MessageSuivant/@interface != @interface">
      
        <xsl:choose>
        
        <!-- si le premier message (entrant) provoque l'emission du second (sortant, - de 100ms d'ecart), alors 2 messages par ligne --> 
         <xsl:when test="($datenumerique + $ToleranceTemporelle) > $datenumeriquesuivante and @direction = 'in' and $MessageSuivant/@direction = 'out'">
          <tr>
            <td valign="top" width="50%">
              <!-- affichage du message courant -->
              <xsl:call-template name="T_AfficheMessage"/>

            </td>
            <td valign="top" width="50%">
                <!-- affichage du message suivant -->
                <xsl:call-template name="T_AfficheMessage">
                  <xsl:with-param name="UnMessage" select="$MessageSuivant"/>
                </xsl:call-template>
            </td>
          </tr>
          <!-- memoristaion de l'ecriture du message suivant -->
          <xsl:value-of select="user:str_SetNonEcrit(1)"/>
        </xsl:when>

        <xsl:otherwise>
          <tr>
            <td width="50%">
              <!-- affichage du message courant -->
              <xsl:call-template name="T_AfficheMessage"/>
            </td>
            <td width="50%"><!-- cellule vide -->&#160;</td>
          </tr>
        </xsl:otherwise>

        </xsl:choose>
         
      </xsl:if>

    </xsl:when>

    <!-- traitement des messages de type Link -->
    <xsl:when test="contains(@interface,'Link_Interface') or contains(@interface,'Slp_Interface')">

      <xsl:if test="$MessageSuivant/@interface = @interface">
        <tr>
          <td width="50%"><!-- cellule vide -->&#160;</td>
          <td width="50%">
            <!-- affichage du message courant -->
            <xsl:call-template name="T_AfficheMessage"/>
          </td>
        </tr>
		
      </xsl:if>

     <xsl:if test="$MessageSuivant/@interface != @interface">
      
        <xsl:choose>
  
        <xsl:when test="($datenumerique + $ToleranceTemporelle) > $datenumeriquesuivante and @direction = 'in' and $MessageSuivant/@direction = 'out'">
          <tr>
            <td valign="top" width="50%">
              <!-- affichage du message suivant-->
              <xsl:call-template name="T_AfficheMessage">
                <xsl:with-param name="UnMessage" select="$MessageSuivant"/>
              </xsl:call-template>
            </td>
            <td valign="top" width="50%">
              <!-- affichage du message courant -->
              <xsl:call-template name="T_AfficheMessage"/>
            </td>
          </tr>
          <xsl:value-of select="user:str_SetNonEcrit(1)"/>
        </xsl:when>

        <xsl:otherwise>
          <tr>
            <td width="50%"><!-- cellule vide -->&#160;</td>
            <td width="50%">
              <!-- affichage du message courant -->
              <xsl:call-template name="T_AfficheMessage"/>
            </td>
          </tr>
       </xsl:otherwise>

        </xsl:choose>
         
      </xsl:if>

    </xsl:when>

    </xsl:choose>

    <!-- Affichage du dernier message --> 
    <xsl:if test="position() = last()">
      <xsl:choose>

        <xsl:when test="contains(@interface,'Host_Interface')">
          <tr>
            <td width="50%">
              <!-- affichage du message courant -->
              <xsl:call-template name="T_AfficheMessage" />
            </td>
            <td width="50%"><!-- cellule vide -->&#160;</td>
          </tr>
        </xsl:when> 
          
        <xsl:when test="contains(@interface,'Link_Interface') or contains(@interface,'Slp_Interface')">
          <tr>
            <td width="50%"><!-- cellule vide -->&#160;</td>
            <td width="50%">
              <!-- affichage du message courant -->
              <xsl:call-template name="T_AfficheMessage" />
            </td>
          </tr>
        </xsl:when> 
        
      </xsl:choose>  

    </xsl:if>

 </xsl:when>
 
 <!-- si le message a deja ete ecrit au tour precedent, on remet NonEcrit a 0 -->
 <xsl:otherwise>
   <xsl:value-of select="user:str_SetNonEcrit(0)" />
 </xsl:otherwise>

 </xsl:choose> 

</xsl:if>

</xsl:template>


<xsl:template name="T_AfficheMessage">

  <!-- parametre UnMessage pour afficher les champs de ce message, message courant par défaut -->
  <xsl:param name="UnMessage" select="." />

  <!-- saut de ligne entre les messages -->
  <xsl:if test="position() != 1">
    <br/>
  </xsl:if>
<font size="2">

  <!-- affichage de la date uniquement pour les messages entrants -->
  <xsl:if test="$UnMessage/@direction = 'in'">
    <xsl:apply-templates select="$UnMessage/messageDate" />&#160;
  </xsl:if>

  <!-- traitement spécifique au type de message (L16 FOM, L16 UJ, L11, HOST) -->

  <xsl:choose>

    <!-- affichage des codeWord pour messages J -->
    <xsl:when test="contains($UnMessage/messageName,'FIM') or contains($UnMessage/messageName,'FOM') or contains($UnMessage/messageName,'UJ')">
      <!-- insertion d'un espace pour la lisbilité : J2.3 I/EO/... -->
      <xsl:value-of select="substring-before($UnMessage/codeWord,'I')"/>
      &#160;I
      <xsl:value-of select="substring-after($UnMessage/codeWord,'I')"/>
      <!-- affiichage des noms des messages pour messages J -->
      <xsl:if test="contains($UnMessage/messageName,'FIM') or contains($UnMessage/messageName,'FOM')">
        <xsl:value-of select="substring($UnMessage/messageName,21,string-length($UnMessage/messageName))"/>
      </xsl:if>
      <xsl:if test="contains($UnMessage/messageName,'UJ')">
        <xsl:value-of select="substring-after($UnMessage/messageName,' ')"/>
      </xsl:if>
    </xsl:when>

    <!-- affichage des messages L11 -->
    <xsl:when test="contains($UnMessage/messageName,'Input') or contains($UnMessage/messageName,'Output')">
      <xsl:value-of select="substring-after($UnMessage/messageName,' ')"/>
    </xsl:when>

    <xsl:otherwise>
      <xsl:apply-templates select="$UnMessage/messageName" />
    </xsl:otherwise>
  </xsl:choose> 

  <!-- affichage de l'interface pour les tests multi-interfaces -->
  <xsl:if test="contains($UnMessage/@interface,'Host') and $NbInterfaceHost > 1">
    <xsl:call-template name="T_AfficheInterface">
      <xsl:with-param name="UnMessage" select="$UnMessage"/>
    </xsl:call-template>
  </xsl:if>
  <xsl:if test="(contains($UnMessage/@interface,'Link') or contains(@interface,'Slp_Interface')) and $NbInterfaceLink > 1">
    <xsl:call-template name="T_AfficheInterface">
      <xsl:with-param name="UnMessage" select="$UnMessage"/>
    </xsl:call-template>
  </xsl:if>

</font> 

  <xsl:call-template name="T_InsereFleche">
    <xsl:with-param name="UnMessage" select="$UnMessage" />
  </xsl:call-template>
  <xsl:call-template name="T_AfficheChamp">
    <xsl:with-param name="UnMessage" select="$UnMessage"/>
  </xsl:call-template>

</xsl:template>


<xsl:template name="T_InsereFleche">

  <!-- parametre UnMessage -->
  <xsl:param name="UnMessage"/>

  <xsl:choose>
    
    <xsl:when test="contains($UnMessage/@interface,'Host_Interface')">

      <xsl:choose>

        <xsl:when test="$UnMessage/@direction = 'in'">
          <br/>
		<xsl:call-template name="T_ImageFleche">
		  <xsl:with-param name="image" select="'rightarrow.bmp'"/>
		</xsl:call-template>
        </xsl:when>

        <xsl:when test="$UnMessage/@direction = 'out'">
          <br/>
		<xsl:call-template name="T_ImageFleche">
		  <xsl:with-param name="image" select="'leftarrow.bmp'"/>
		</xsl:call-template>
        </xsl:when>

      </xsl:choose>

    </xsl:when>

    <xsl:when test="contains($UnMessage/@interface,'Link_Interface') or contains($UnMessage/@interface,'Slp_Interface')">
      
      <xsl:choose>

        <xsl:when test="$UnMessage/@direction = 'in'">
          <br/>
		<xsl:call-template name="T_ImageFleche">
		  <xsl:with-param name="image" select="'leftarrow.bmp'"/>
		</xsl:call-template>
        </xsl:when>

        <xsl:when test="$UnMessage/@direction = 'out'">
          <br/>
		<xsl:call-template name="T_ImageFleche">
		  <xsl:with-param name="image" select="'rightarrow.bmp'"/>
		</xsl:call-template>
        </xsl:when>

      </xsl:choose>
      
    </xsl:when>

  </xsl:choose>

</xsl:template>


<xsl:template name="T_AfficheChamp">
 
 <!-- parametre UnMessage pour afficher les champs de ce message -->
 <xsl:param name="UnMessage"/>

 <font size="1">

  <xsl:for-each select="$UnMessage/field" >
    
    <xsl:variable name="AFieldName">
      <xsl:value-of select="fieldName"/>
    </xsl:variable>
    <xsl:variable name="AFieldValue">
      <xsl:value-of select="fieldValue"/>
    </xsl:variable>
    <!-- remplacement des _ par des espaces pour éviter les mots trop longs qui agrandissent la largeur de la colonne -->
    <xsl:value-of select="translate($AFieldName,'_',' ')" /> = <xsl:value-of select="translate($AFieldValue,'_',' ')" />
    <br/>
  </xsl:for-each>

</font>

</xsl:template>


<xsl:template name="T_ConversionDate">

  <xsl:param name="UnMessage" select="."/>

  <!-- le format de la date dans le XMl est ##:##:##.### qu'il faut convertir au format numérique ######.### -->
  <xsl:value-of select="number (concat (substring($UnMessage/messageDate,1,2),substring($UnMessage/messageDate,4,2),substring($UnMessage/messageDate,7,6) ) )"  />

</xsl:template>


<!-- Template qui insere l'image de la fleche -->
<xsl:template name="T_ImageFleche">

  <!-- Parametre : nom du fichier image -->
  <xsl:param name="image"/>
	<!-- insere la premiere partie de la balise image : <img src=" -->
	<xsl:text disable-output-escaping="yes">	
      &lt;img src="
	</xsl:text>

	<!-- insere le chemin de l'image -->
	<xsl:value-of select="concat($StylesheetFilePath, $image)"/>

	<!-- insere la derniere partie de la balise image : "/> -->
	<xsl:text disable-output-escaping="yes">
	  " border="0"/&gt;
	</xsl:text><br/>
</xsl:template>    

<!-- Template qui affiche le nom du step.
     Si le step n'a pas de nom, affiche :"Step 1" où 1 est l'Id du step -->
<xsl:template name="T_AfficheStep">
  <xsl:choose>
    <xsl:when test="stepName != ''">
      <xsl:choose>
        <xsl:when test="$NbCarMaxColStep > string-length(stepName)">
          <xsl:value-of select="stepName"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="T_CoupeChaine">
            <xsl:with-param name="NbCarMax" select="$NbCarMaxColStep"/>
            <xsl:with-param name="LaChaine" select="stepName"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      Step <xsl:value-of select="@idNumber"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Template qui affiche l'interface du message -->
<xsl:template name="T_AfficheInterface">
  <xsl:param name="UnMessage"/>
  <xsl:choose>
    <xsl:when test="$UnMessage/@direction = 'in'">
      from <xsl:value-of select="$UnMessage/@interface"/>
    </xsl:when>
    <xsl:when test="$UnMessage/@direction = 'out'">
      to <xsl:value-of select="$UnMessage/@interface"/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- Template qui affiche le resultat -->
<xsl:template name="T_AfficheResultat">

  <xsl:variable name="UnResultat">
    <xsl:value-of select="stepResult"/>
  </xsl:variable>

  <xsl:choose>
  <xsl:when test="$UnResultat != ''">
    <b><u>Result :</u></b>&#160;<xsl:value-of select="translate($UnResultat,'_',' ')"/>
    <br/>
  </xsl:when>
  <xsl:otherwise>
    &#160;
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Template qui affiche les FT -->
<xsl:template name="T_AfficheFT">
  <!-- les FT ne sont affichés que si le champ resultat n'est pas vide -->
  <xsl:if test="stepResult != ''">
    <xsl:if test="stepFT != ''">
      <b><u>FT :</u></b>
      <br/>
    </xsl:if>
    <xsl:for-each select="stepFT">
      <xsl:choose>
        <xsl:when test="$NbCarMaxColResult > string-length(.)">
          <xsl:value-of select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="T_CoupeChaine">
            <xsl:with-param name="NbCarMax" select="$NbCarMaxColResult"/>
            <xsl:with-param name="LaChaine" select="."/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <br/>
    </xsl:for-each>
  </xsl:if>
</xsl:template>

<!--Template qui permet de couper les chaines de caractères trop longues -->
<xsl:template name="T_CoupeChaine">
  <xsl:param name="NbCarMax"/>
  <xsl:param name="LaChaine"/>
<!-- TODO : remplacer la valeur par défaut '- ' par un retour à la ligne -->  
  <xsl:param name="ChaineCoupure" select="'- '"/>
  <xsl:value-of select="substring($LaChaine,1,$NbCarMax)"/>
  <xsl:value-of select="$ChaineCoupure"/>
  <xsl:value-of select="substring($LaChaine,$NbCarMax + 1)"/>
</xsl:template>

<msxsl:script language="JavaScript" implements-prefix="user">

	m_strNonEcrit=0; //par défaut non ecrit, 1 si message deja ecrit
	
	function str_SetNonEcrit(a_strIdentifiant)
	{
		m_strNonEcrit=a_strIdentifiant;
		return "";
	}

	function str_GetNonEcrit()
	{
		return m_strNonEcrit;
	}

</msxsl:script>

</xsl:stylesheet>
