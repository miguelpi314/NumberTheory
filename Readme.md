# How to install Sagemath.

## Step 1: Add the *conda-forge* channel.

- Add the conda-forge channel: `conda config --add channels conda-forge`
- Change channel priority to strict: `conda config --set channel_priority strict`


## Step 2: Create an enviroment with conda

`conda create -n NAME_OF_THE_ENVIROMENT sage python= VERSION`

## Step 3: Check the installation 

- Activate the new environment: `conda activate sage`
- Check sage version: `sage --version`

---

# L-functions and Modular Forms database

## Preparing the set-up
- Go to your code directory and write on a terminal `git clone https://github.com/LMFDB/lmfdb.git lmfdb`
- Install Sagemath
- Install the necessary sagemath packages to run everything. Execute: 

    `sage -i gap_packages`

    `sage -i database_gap # only needed if sage version < 8.6`

    `sage -i pip`

    `sage -b # in the 'lmfdb/' directory:`

    `sage -pip install -r requirements.txt`

- Add to your anaconda environment the lmfdb repository with 
`conda develop /home/user/code/lmfdb`

Now you should can access to lmfdb in a python console or sage console executing
`from lmdfb import db`

## How to make queries to lmfdb

Lmfdb has several tables that can be found [here](https://www.lmfdb.org/api/)

In order to access them with python or Sage execute the following
    
    from lmdfb import db
    db.TABLE_NAME.METHOD

Let's see the most useful methods:

Firstly, the basic search method:

    db.TABLE_NAME.search()

    def search(
        self,
        query={},
        projection=1,
        limit=None,
        offset=0,
        sort=None,
        info=None,
        split_ors=False,
        one_per=None,
        silent=False,
        raw=None,
        raw_values=[],
    ):
        """
        One of the two main public interfaces for performing SELECT queries,
        intended for usage from search pages where multiple results may be returned.

        INPUT:

        - ``query`` -- a mongo-style dictionary specifying the query.
           Generally, the keys will correspond to columns,
           and values will either be specific numbers (specifying an equality test)
           or dictionaries giving more complicated constraints.
           The main exception is that "$or" can be a top level key,
           specifying a list of constraints of which at least one must be true.
        - ``projection`` -- which columns are desired.
          This can be specified either as a list of columns to include;
           a dictionary specifying columns to include (using all True values)
                                           or exclude (using all False values);
           a string giving a single column (only returns the value, not a dictionary);
           or an integer code (0 means only return the label,
                               1 means return all search columns (default),
                               2 means all columns).
        - ``limit`` -- an integer or None (default), giving the maximum number of records to return.
        - ``offset`` -- a nonnegative integer (default 0), where to start in the list of results.
        - ``sort`` -- a sort order.  Either None or a list of strings (which are interpreted as column names in the ascending direction) or of pairs (column name, 1 or -1).  If not specified, will use the default sort order on the table.  If you want the result unsorted, use [].
        - ``info`` -- a dictionary, which is updated with values of 'query', 'count', 'start', 'exact_count' and 'number'.  Optional.
        - ``split_ors`` -- a boolean.  If true, executes one query per clause in the `$or` list, combining the results.  Only used when a limit is provided.
        - ``one_per`` -- a list of columns.  If provided, only one result will be included with each given set of values for those columns (the first according to the provided sort order).
        - ``silent`` -- a boolean.  If True, slow query warnings will be suppressed.
        - ``raw`` -- a string, to be used as the WHERE part of the query.  DO NOT USE THIS DIRECTLY FOR INPUT FROM WEBSITE.
        - ``raw_values`` -- a list of values to be substituted for %s entries in the raw string.  Useful when strings might include quotes.

        WARNING:

        For tables that are split into a search table and an extras table,
        requesting columns in the extras table via this function will
        require a separate database query for EACH ROW of the result.
        This function is intended for use only on the columns in the search table.

        OUTPUT:

        If ``limit`` is None, returns an iterator over the results, yielding dictionaries with keys the columns requested by the projection (or labels/column values if the projection is 0 or a string)

        Otherwise, returns a list with the same data.

        EXAMPLES::

            sage: from lmfdb import db
            sage: nf = db.nf_fields
            sage: info = {}
            sage: nf.search({'degree':int(2),'class_number':int(1),'disc_sign':int(-1)}, projection=0, limit=4, info=info)
            [u'2.0.3.1', u'2.0.4.1', u'2.0.7.1', u'2.0.8.1']
            sage: info['number'], info['exact_count']
            (9, True)
            sage: info = {}
            sage: nf.search({'degree':int(6)}, projection=['label','class_number','galt'], limit=4, info=info)
            [{'class_number': 1, 'galt': 5, 'label': u'6.0.9747.1'},
             {'class_number': 1, 'galt': 11, 'label': u'6.0.10051.1'},
             {'class_number': 1, 'galt': 11, 'label': u'6.0.10571.1'},
             {'class_number': 1, 'galt': 5, 'label': u'6.0.10816.1'}]
            sage: info['number'], info['exact_count']
            (5522600, True)
            sage: info = {}
            sage: nf.search({'ramps':{'$contains':[int(2),int(7)]}}, limit=4, info=info)
            [{'label': u'2.2.28.1', 'ramps': [2, 7]},
             {'label': u'2.0.56.1', 'ramps': [2, 7]},
             {'label': u'2.2.56.1', 'ramps': [2, 7]},
             {'label': u'2.0.84.1', 'ramps': [2, 3, 7]}]
            sage: info['number'], info['exact_count']
            (1000, False)
        """

Secondly, the join search method

    db.TABLE_NAME.join_search()
    
    def join_search(
        self,
        query={},
        projection=1,
        join=[],
        limit=None,
        offset=0,
        sort=None,
        info=None,
        one_per=None,
        silent=False,
    ):
        """
        A version of search that can also include columns from other tables.

        Does not support the parameters raw, split_ors from search.

        INPUT:

        - ``query`` -- either a dictionary (in which case all constraints are on this table) or a list of pairs ``(table, dictionary)``
        - ``projection`` -- a list with entries that are either strings (column names from this table),
            or pairs ``(table, column)``; or an integer (with meaning the same as for search())
        - ``join`` -- a list of quadruples (tbl1, col1, tbl2, col2).  tbl1 should have already appeared (or be self for the first entry), while tbl2 should be new
        - ``sort`` -- if provided, can only contain columns from this table (for simplicity)

        EXAMPLES::

            sage: db.ec_nfcurves.join_search({"rank":1}, ["label", ("nf_fields", "r2")], [("ec_nfcurves", "field_label", "nf_fields", "label")], limit=3)
            [{'label': '2.0.11.1-47.1-a1', ('nf_fields', 'r2'): 1},
             {'label': '2.0.11.1-47.2-a1', ('nf_fields', 'r2'): 1},
             {'label': '2.0.11.1-108.1-a1', ('nf_fields', 'r2'): 1}]
        """