
class Periscope

    isLoaded: false
    StaticKey: ''
    servers = {}

    upScope: (opts) ->

        @$main = $('#main')
        @servers = opts.servers
        @keys = opts.keys
        @regexOverride = opts.listOverride

        # Check url params here
        request = opts.defaults
        urlparams = @parseUrlParams(opts.keys)

        for param, idx in @keys
            if urlparams[param] then request[idx] = urlparams[param]

        @updateNavBar(request)
        @loadServers(request)

    updateNavBar: (dataArry) ->

        nb = $('#nav-bar')
        out = []
        currentServers = @servers

        for key, idx in @keys
            h = @confirmHost(currentServers, dataArry[idx])
            if @regexOverride[key]?[dataArry[idx]]
                h = dataArry[idx]

            out.push '<li class="dropdown">',
                '<a href="#" class="dropdown-toggle" data-toggle="dropdown">', key , ': <b>', h, '</b><b class="caret"></b></a>',
                '<ul class="dropdown-menu">'

            if @regexOverride[@keys[idx]]
                for cidx, child of Object.keys(@regexOverride[key])
                    if child != h then out.push '<li><a href="#" data-env="', key, '">', child, '</a></li>'
            else
                for child of currentServers
                    out.push '<li><a href="#" data-env="', key, '">', child, '</a></li>'
            out.push '</ul></li>'
            if idx < @keys.length - 1
                currentServers = currentServers[h]
        nb.append(out.join(''))

        $( "a" ).click (e) =>
            attrName = $(e.currentTarget).attr('data-env')
            attrVal  = $(e.currentTarget)[0].innerText
            if @keys.indexOf(attrName) != -1
                $url = $.url()
                url = $url.attr('source')
                currentAttr = $url.param(attrName)
                if url.indexOf(attrName) != -1
                    url = url.replace("#{attrName}=#{currentAttr}", "#{attrName}=#{attrVal}")
                else
                    if url.indexOf('?') != -1 then url += "&" else url += '?'
                    url += "#{attrName}=#{attrVal}"
                location.href = url

        return

    confirmHost: (obj, key) ->

        keys = Object.keys(obj)
        return key if keys.indexOf(key) != -1
        return keys[0] if keys.length > 0
        return false

    loadServers: (dataArry) ->

        @$main.empty()
        html = ''

        currentServers = @servers
        domainstr = false
        keyIdx = 0
        while dataArry.length
            h = dataArry.shift()
            if @regexOverride[@keys[keyIdx]]
                hostList = []
                for host in currentServers
                    hostList.push(host) if @regexOverride[@keys[keyIdx]][h].exec(host)
                currentServers = hostList
            else
                h = @confirmHost(currentServers, h)

                if domainstr is false
                    domainstr = h
                else
                    domainstr = h + '.' + domainstr

                currentServers = currentServers[h]
            keyIdx++


        for host in currentServers
            hostname = "#{host}.#{domainstr}"
            url = 'http://' + hostname
            html += '<div class="servers"><h2>' + hostname + ' <i class="fa fa-refresh"></i></h2>' +
                '<iframe src="' + url + '" width="320"  height="480" scrolling="no"></iframe></div>'
        @$main.html(html)
        return

    stripTrailingSlash: (str) ->
        if str?.substr(-1) == '/'
            return str.substr(0, str.length - 1)
        return str

    parseUrlParams: (keys) ->
        # get the current page url
        $url = $.url()

        obj = {}
        for key in keys
            if $url.param(key)
                obj[key] = @stripTrailingSlash($url.param(key))
        return obj

window.Periscope = new Periscope()

